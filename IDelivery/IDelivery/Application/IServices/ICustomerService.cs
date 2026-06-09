using IDelivery.Application.DTOs.Customers;

namespace IDelivery.Application.IServices;

public interface ICustomerService
{
    Task<CustomerMeDto?> GetMeAsync(Guid userId, CancellationToken ct = default);
    Task<CustomerMeDto?> UpdateMeAsync(Guid userId, UpdateCustomerMeRequestDto request, CancellationToken ct = default);
    Task<AddressDto> AddAddressAsync(Guid userId, UpsertCustomerAddressRequestDto request, CancellationToken ct = default);
    Task<List<AddressDto>> GetAddressesAsync(Guid userId, CancellationToken ct = default);
    Task<bool> UpdateAddressAsync(Guid userId, Guid addressId, UpsertCustomerAddressRequestDto request, CancellationToken ct = default);
    Task<bool> DeleteAddressAsync(Guid userId, Guid addressId, CancellationToken ct = default);
    Task<Guid> GetCustomerIdAsync(Guid userId, CancellationToken ct = default);
}
