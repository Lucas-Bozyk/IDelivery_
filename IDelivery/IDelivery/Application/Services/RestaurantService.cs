using AutoMapper;
using IDelivery.Application.DTOs.Products;
using IDelivery.Application.DTOs.Restaurants;
using IDelivery.Application.DTOs.Reviews;
using IDelivery.Application.IServices;
using IDelivery.Application.Ports;
using IDelivery.Application.UseCases;
using IDelivery.Domain;
using IDelivery.Domain.Interfaces.IRepositories;

namespace IDelivery.Application.Services;

public class RestaurantService(
    IRestaurantRepository restaurants,
    IProductRepository products,
    IUnitOfWork unitOfWork,
    IRestaurantOwnershipPort restaurantOwnership,
    CreateRestaurantUseCase createRestaurantUseCase,
    IMapper mapper) : IRestaurantService
{
    public async Task<List<RestaurantDto>> GetAllAsync(CancellationToken ct = default) =>
        mapper.Map<List<RestaurantDto>>(await restaurants.GetAllAsync(ct));

    public async Task<RestaurantDto?> GetAsync(Guid id, CancellationToken ct = default)
    {
        var r = await restaurants.GetByIdAsync(id, ct);
        return r is null ? null : mapper.Map<RestaurantDto>(r);
    }

    public async Task<Restaurant> CreateAsync(Guid userId, bool isAdmin, CreateRestaurantCommand command, CancellationToken ct = default)
    {
        var ownedRestaurantId = await restaurantOwnership.GetOwnedRestaurantIdAsync(userId, ct);
        if (!isAdmin && ownedRestaurantId.HasValue)
            throw new UnauthorizedAccessException("Restaurant owner already has a restaurant.");

        var restaurant = await createRestaurantUseCase.ExecuteAsync(command, ct);
        if (!isAdmin) await restaurantOwnership.AssignRestaurantToOwnerAsync(userId, restaurant.Id, ct);
        return restaurant;
    }

    public async Task<bool> UpdateAsync(Guid userId, bool isAdmin, Guid id, UpdateRestaurantRequestDto request, CancellationToken ct = default)
    {
        await EnsureRestaurantAccessAsync(userId, isAdmin, id, ct);
        var entity = await restaurants.GetByIdAsync(id, ct);
        if (entity is null) return false;
        entity.Name = request.Name;
        entity.Description = request.Description;
        entity.Cnpj = request.Cnpj;
        entity.Phone = request.Phone;
        entity.Email = request.Email;
        entity.ProfileImageUrl = ProductImagePath.Normalize(request.ProfileImageUrl);
        entity.CategoryId = request.CategoryId;
        entity.UpdatedAt = DateTime.UtcNow;
        await restaurants.UpdateAsync(entity, ct);
        await unitOfWork.SaveChangesAsync(ct);
        return true;
    }

    public async Task<bool> UpdateOpenStatusAsync(Guid userId, bool isAdmin, Guid id, bool isOpen, CancellationToken ct = default)
    {
        await EnsureRestaurantAccessAsync(userId, isAdmin, id, ct);
        var entity = await restaurants.GetByIdAsync(id, ct);
        if (entity is null) return false;
        entity.IsOpen = isOpen;
        entity.UpdatedAt = DateTime.UtcNow;
        await restaurants.UpdateAsync(entity, ct);
        await unitOfWork.SaveChangesAsync(ct);
        return true;
    }

    public async Task<List<ProductDto>> GetProductsAsync(Guid restaurantId, CancellationToken ct = default) =>
        mapper.Map<List<ProductDto>>(await products.GetByRestaurantAsync(restaurantId, ct));

    public async Task<ProductDto> CreateProductAsync(Guid userId, bool isAdmin, Guid restaurantId, CreateProductRequestDto request, CancellationToken ct = default)
    {
        await EnsureRestaurantAccessAsync(userId, isAdmin, restaurantId, ct);
        var product = new Product
        {
            RestaurantId = restaurantId,
            MenuCategoryId = request.MenuCategoryId,
            Name = request.Name,
            Description = request.Description,
            Price = request.Price,
            PromotionalPrice = request.PromotionalPrice,
            IsAvailable = request.IsAvailable,
            ImageUrl = ProductImagePath.Normalize(request.ImageUrl)
        };
        await products.AddAsync(product, ct);
        await unitOfWork.SaveChangesAsync(ct);
        return mapper.Map<ProductDto>(product);
    }

    public async Task<List<ReviewDto>> GetReviewsAsync(Guid restaurantId, CancellationToken ct = default) =>
        mapper.Map<List<ReviewDto>>(await restaurants.GetReviewsAsync(restaurantId, ct));

    private async Task EnsureRestaurantAccessAsync(Guid userId, bool isAdmin, Guid restaurantId, CancellationToken ct)
    {
        if (isAdmin) return;
        var userRestaurantId = await restaurantOwnership.GetOwnedRestaurantIdAsync(userId, ct);
        if (userRestaurantId != restaurantId)
            throw new UnauthorizedAccessException("Restaurant does not belong to this user.");
    }
}
