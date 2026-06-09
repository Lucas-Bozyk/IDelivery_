using IDelivery.Domain;
using IDelivery.Application.Ports;
using IDelivery.Application.Services;

namespace IDelivery.Application.UseCases;

public record CreateRestaurantCommand(string Name, string Description, string Cnpj, string Phone, string Email, Guid CategoryId, string? ProfileImageUrl = null);

public class CreateRestaurantUseCase(ICreateRestaurantRepository repository)
{
    public async Task<Restaurant> ExecuteAsync(CreateRestaurantCommand command, CancellationToken ct = default)
    {
        var restaurant = new Restaurant
        {
            Name = command.Name,
            Description = command.Description,
            Cnpj = command.Cnpj,
            Phone = command.Phone,
            Email = command.Email,
            ProfileImageUrl = ProductImagePath.Normalize(command.ProfileImageUrl),
            CategoryId = command.CategoryId,
            IsOpen = true
        };
        await repository.AddRestaurantAsync(restaurant, ct);
        await repository.SaveChangesAsync(ct);
        return restaurant;
    }
}
