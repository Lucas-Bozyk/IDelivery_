namespace IDelivery.Application.DTOs.Restaurants;

public record RestaurantDto(
    Guid Id,
    string Name,
    string Description,
    string Cnpj,
    string Phone,
    string Email,
    string? ProfileImageUrl,
    bool IsOpen,
    Guid CategoryId,
    DateTime CreatedAt,
    DateTime UpdatedAt);
