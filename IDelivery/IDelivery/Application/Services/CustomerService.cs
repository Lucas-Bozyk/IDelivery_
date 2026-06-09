using AutoMapper;
using IDelivery.Application.DTOs.Customers;
using IDelivery.Application.IServices;
using IDelivery.Application.Ports;
using IDelivery.Domain;
using IDelivery.Domain.Interfaces.IRepositories;

namespace IDelivery.Application.Services;

public class CustomerService(ICustomerRepository customers, ICustomerProfileRepository customerProfiles, IMapper mapper) : ICustomerService
{
    public async Task<CustomerMeDto?> GetMeAsync(Guid userId, CancellationToken ct = default)
    {
        var customer = await customers.GetByUserIdAsync(userId, ct);
        return customer is null ? null : mapper.Map<CustomerMeDto>(customer);
    }

    public async Task<List<AddressDto>> GetAddressesAsync(Guid userId, CancellationToken ct = default)
    {
        var customer = await customers.GetByUserIdAsync(userId, ct);
        if (customer is null) return [];
        var addresses = await customers.GetAddressesAsync(customer.Id, ct);
        return mapper.Map<List<AddressDto>>(addresses);
    }

    public async Task<CustomerMeDto?> UpdateMeAsync(Guid userId, UpdateCustomerMeRequestDto request, CancellationToken ct = default)
    {
        var customer = await customerProfiles.GetByUserIdAsync(userId, ct);
        if (customer is null) return null;
        customer.FullName = request.FullName;
        customer.Phone = request.Phone;
        customer.UpdatedAt = DateTime.UtcNow;
        await customerProfiles.SaveChangesAsync(ct);
        return mapper.Map<CustomerMeDto>(customer);
    }

    public async Task<AddressDto> AddAddressAsync(Guid userId, UpsertCustomerAddressRequestDto request, CancellationToken ct = default)
    {
        var customerId = await GetCustomerIdAsync(userId, ct);
        var address = new CustomerAddress
        {
            CustomerId = customerId,
            Street = request.Street,
            Number = request.Number,
            Complement = request.Complement,
            Neighborhood = request.Neighborhood,
            City = request.City,
            State = request.State,
            ZipCode = request.ZipCode,
            IsDefault = request.IsDefault
        };
        await customerProfiles.AddAddressAsync(address, ct);
        await customerProfiles.SaveChangesAsync(ct);
        return mapper.Map<AddressDto>(address);
    }

    public async Task<bool> UpdateAddressAsync(Guid userId, Guid addressId, UpsertCustomerAddressRequestDto request, CancellationToken ct = default)
    {
        var customerId = await GetCustomerIdAsync(userId, ct);
        var address = await customerProfiles.GetAddressAsync(customerId, addressId, ct);
        if (address is null) return false;
        address.Street = request.Street;
        address.Number = request.Number;
        address.Complement = request.Complement;
        address.Neighborhood = request.Neighborhood;
        address.City = request.City;
        address.State = request.State;
        address.ZipCode = request.ZipCode;
        address.IsDefault = request.IsDefault;
        await customerProfiles.SaveChangesAsync(ct);
        return true;
    }

    public async Task<bool> DeleteAddressAsync(Guid userId, Guid addressId, CancellationToken ct = default)
    {
        var customerId = await GetCustomerIdAsync(userId, ct);
        var address = await customerProfiles.GetAddressAsync(customerId, addressId, ct);
        if (address is null) return false;
        customerProfiles.RemoveAddress(address);
        await customerProfiles.SaveChangesAsync(ct);
        return true;
    }

    public async Task<Guid> GetCustomerIdAsync(Guid userId, CancellationToken ct = default)
    {
        var customer = await customers.GetByUserIdAsync(userId, ct);
        if (customer is null) throw new InvalidOperationException("Customer profile not found.");
        return customer.Id;
    }
}
