namespace IDelivery.Application.DTOs.Reviews;

public record ReviewDto(Guid Id, Guid CustomerId, Guid RestaurantId, Guid OrderId, int Rating, string Comment, DateTime CreatedAt);
