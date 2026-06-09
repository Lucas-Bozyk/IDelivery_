using AutoMapper;
using IDelivery.Application.DTOs.Products;
using IDelivery.Application.IServices;
using IDelivery.Application.Ports;
using IDelivery.Domain.Interfaces.IRepositories;

namespace IDelivery.Application.Services;

public class ProductService(
    IProductRepository products,
    IUnitOfWork unitOfWork,
    IRestaurantOwnershipPort restaurantOwnership,
    IMapper mapper) : IProductService
{
    public async Task<List<ProductDto>> GetByRestaurantAsync(Guid restaurantId, CancellationToken ct = default) =>
        mapper.Map<List<ProductDto>>(await products.GetByRestaurantAsync(restaurantId, ct));

    public async Task<ProductDto?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        var product = await products.GetByIdAsync(id, ct);
        return product is null ? null : mapper.Map<ProductDto>(product);
    }

    public async Task<bool> UpdateAsync(Guid userId, bool isAdmin, Guid id, UpdateProductRequestDto request, CancellationToken ct = default)
    {
        var entity = await products.GetByIdAsync(id, ct);
        if (entity is null) return false;
        await EnsureRestaurantAccessAsync(userId, isAdmin, entity.RestaurantId, ct);
        entity.Name = request.Name;
        entity.Description = request.Description;
        entity.Price = request.Price;
        entity.PromotionalPrice = request.PromotionalPrice;
        entity.IsAvailable = request.IsAvailable;
        entity.ImageUrl = ProductImagePath.Normalize(request.ImageUrl);
        entity.MenuCategoryId = request.MenuCategoryId;
        entity.UpdatedAt = DateTime.UtcNow;
        await products.UpdateAsync(entity, ct);
        await unitOfWork.SaveChangesAsync(ct);
        return true;
    }

    public async Task<bool> DeleteAsync(Guid userId, bool isAdmin, Guid id, CancellationToken ct = default)
    {
        var entity = await products.GetByIdAsync(id, ct);
        if (entity is null) return false;
        await EnsureRestaurantAccessAsync(userId, isAdmin, entity.RestaurantId, ct);
        await products.DeleteAsync(entity, ct);
        await unitOfWork.SaveChangesAsync(ct);
        return true;
    }

    private async Task EnsureRestaurantAccessAsync(Guid userId, bool isAdmin, Guid restaurantId, CancellationToken ct)
    {
        if (isAdmin) return;
        var userRestaurantId = await restaurantOwnership.GetOwnedRestaurantIdAsync(userId, ct);
        if (userRestaurantId != restaurantId)
            throw new UnauthorizedAccessException("Product does not belong to this restaurant owner.");
    }
}
