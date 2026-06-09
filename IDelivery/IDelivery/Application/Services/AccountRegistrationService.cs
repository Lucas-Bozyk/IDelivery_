using IDelivery.Application.DTOs.Auth;
using IDelivery.Application.IServices;
using IDelivery.Application.Ports;
using IDelivery.Domain;
using IDelivery.Domain.ValueObjects;

namespace IDelivery.Application.Services;

public class AccountRegistrationService(IAccountProfileRepository profiles) : IAccountRegistrationService
{
    public async Task CreateDomainProfileAsync(User user, UserRole role, RegisterRequestDto request, CancellationToken ct = default)
    {
        switch (role)
        {
            case UserRole.Customer:
                await CreateCustomerAsync(user, request.Name.Trim(), ct);
                break;
            case UserRole.DeliveryDriver:
                await CreateDeliveryDriverAsync(user, request.Name.Trim(), ct);
                break;
            case UserRole.RestaurantOwner:
                await CreateRestaurantAsync(user, request.Name.Trim(), request.Email.Trim().ToLowerInvariant(), ct);
                break;
            default:
                throw new InvalidOperationException("Role cannot be registered publicly.");
        }
    }

    private async Task CreateCustomerAsync(User user, string name, CancellationToken ct)
    {
        var existing = await profiles.GetCustomerByUserIdAsync(user.Id, ct);
        if (existing is not null)
        {
            user.CustomerId = existing.Id;
            return;
        }

        var customer = new Customer
        {
            UserId = user.Id,
            FullName = name,
            Phone = new PhoneNumber("11999999999").Value
        };
        await profiles.AddCustomerAsync(customer, ct);
        await profiles.SaveChangesAsync(ct);
        user.CustomerId = customer.Id;
    }

    private async Task CreateDeliveryDriverAsync(User user, string name, CancellationToken ct)
    {
        if (user.DeliveryDriverId.HasValue) return;

        var driver = new DeliveryDriver { Name = name };
        await profiles.AddDeliveryDriverAsync(driver, ct);
        await profiles.SaveChangesAsync(ct);
        user.DeliveryDriverId = driver.Id;
    }

    private async Task CreateRestaurantAsync(User user, string name, string email, CancellationToken ct)
    {
        if (user.RestaurantId.HasValue) return;

        var existing = await profiles.GetRestaurantByEmailAsync(email, ct);
        if (existing is not null)
        {
            user.RestaurantId = existing.Id;
            return;
        }

        var category = await profiles.GetFirstRestaurantCategoryAsync(ct);
        if (category is null)
        {
            category = new RestaurantCategory { Name = "Geral" };
            await profiles.AddRestaurantCategoryAsync(category, ct);
            await profiles.SaveChangesAsync(ct);
        }

        var restaurant = new Restaurant
        {
            Name = name,
            Description = $"Restaurante {name}",
            Cnpj = GenerateStableDigits(email, 14),
            Phone = "11999999999",
            Email = email,
            IsOpen = true,
            CategoryId = category.Id
        };
        await profiles.AddRestaurantAsync(restaurant, ct);
        await profiles.SaveChangesAsync(ct);
        user.RestaurantId = restaurant.Id;
    }

    private static string GenerateStableDigits(string value, int length)
    {
        var hash = Math.Abs(value.GetHashCode()).ToString();
        return hash.PadLeft(length, '0')[..length];
    }
}
