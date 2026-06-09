using IDelivery.Application.DTOs.Restaurants;
using IDelivery.Application.DTOs.Products;
using IDelivery.Application.DTOs.Reviews;
using IDelivery.Domain;
using IDelivery.Application.UseCases;

namespace IDelivery.Application.IServices;

public interface IRestaurantService
{
    Task<List<RestaurantDto>> GetAllAsync(CancellationToken ct = default);
    Task<RestaurantDto?> GetAsync(Guid id, CancellationToken ct = default);
    Task<Restaurant> CreateAsync(Guid userId, bool isAdmin, CreateRestaurantCommand command, CancellationToken ct = default);
    Task<bool> UpdateAsync(Guid userId, bool isAdmin, Guid id, UpdateRestaurantRequestDto request, CancellationToken ct = default);
    Task<bool> UpdateOpenStatusAsync(Guid userId, bool isAdmin, Guid id, bool isOpen, CancellationToken ct = default);
    Task<List<ProductDto>> GetProductsAsync(Guid restaurantId, CancellationToken ct = default);
    Task<ProductDto> CreateProductAsync(Guid userId, bool isAdmin, Guid restaurantId, CreateProductRequestDto request, CancellationToken ct = default);
    Task<List<ReviewDto>> GetReviewsAsync(Guid restaurantId, CancellationToken ct = default);
}
