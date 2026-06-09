using IDelivery.Domain;

namespace IDelivery.Application.DTOs.Common;

public record CategoryDto(Guid Id, string Name);

public record CustomerOrderSummaryDto(
    Guid Id,
    Guid CustomerId,
    Guid RestaurantId,
    string RestaurantName,
    OrderStatus Status,
    decimal Subtotal,
    decimal DeliveryFee,
    decimal Discount,
    decimal Total,
    DateTime CreatedAt,
    DateTime? ConfirmedAt,
    DateTime? CancelledAt,
    DateTime? CompletedAt);

public record RestaurantOrderSummaryDto(
    Guid Id,
    OrderStatus Status,
    decimal Total,
    decimal Subtotal,
    decimal DeliveryFee,
    decimal Discount,
    DateTime CreatedAt);

public record RestaurantOrderItemDto(
    Guid Id,
    Guid ProductId,
    string ProductName,
    decimal UnitPrice,
    int Quantity,
    decimal TotalPrice,
    string? Observation);

public record RestaurantOrderDetailsDto(RestaurantOrderSummaryDto Order, List<RestaurantOrderItemDto> Items);

public record DriverDeliveryDto(
    Guid Id,
    Guid OrderId,
    Guid? DeliveryDriverId,
    DeliveryStatus Status,
    string AddressSnapshot,
    DateTime EstimatedDeliveryTime,
    DateTime? DeliveredAt,
    DateTime CreatedAt,
    Guid RestaurantId,
    string RestaurantName);
