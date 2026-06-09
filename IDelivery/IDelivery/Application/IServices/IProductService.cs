using IDelivery.Application.DTOs.Products;

namespace IDelivery.Application.IServices;

public interface IProductService
{
    Task<List<ProductDto>> GetByRestaurantAsync(Guid restaurantId, CancellationToken ct = default);
    Task<ProductDto?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<bool> UpdateAsync(Guid userId, bool isAdmin, Guid id, UpdateProductRequestDto request, CancellationToken ct = default);
    Task<bool> DeleteAsync(Guid userId, bool isAdmin, Guid id, CancellationToken ct = default);
}
