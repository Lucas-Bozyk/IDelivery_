namespace IDelivery.Application.DTOs.Products;

public record ProductDto(
    Guid Id,
    Guid RestaurantId,
    Guid MenuCategoryId,
    string Name,
    string Description,
    decimal Price,
    decimal? PromotionalPrice,
    bool IsAvailable,
    string? ImageUrl);
