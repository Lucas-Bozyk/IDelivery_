using IDelivery.Application.DTOs.Carts;
using IDelivery.Application.DTOs.Common;
using IDelivery.Application.DTOs.Coupons;
using IDelivery.Application.DTOs.Deliveries;
using IDelivery.Application.DTOs.Payments;
using IDelivery.Application.DTOs.Reviews;
using IDelivery.Application.UseCases;
using IDelivery.Domain;

namespace IDelivery.Application.IServices;

public interface ICatalogService
{
    Task<List<CategoryDto>> GetMenuCategoriesAsync(CancellationToken ct = default);
    Task<List<CategoryDto>> GetRestaurantCategoriesAsync(CancellationToken ct = default);
}

public interface ICartService
{
    Task<CartDto?> GetActiveCartAsync(Guid userId, CancellationToken ct = default);
    Task<CartDto> AddItemAsync(Guid userId, AddProductToCartCommand command, CancellationToken ct = default);
    Task<bool> UpdateItemAsync(Guid userId, Guid itemId, int quantity, CancellationToken ct = default);
    Task<bool> RemoveItemAsync(Guid userId, Guid itemId, CancellationToken ct = default);
    Task ClearAsync(Guid userId, CancellationToken ct = default);
}

public interface IPaymentService
{
    Task<PaymentDto> CreateAsync(Guid userId, ProcessPaymentRequestDto request, CancellationToken ct = default);
    Task ProcessWebhookAsync(Guid paymentId, string? providedSignature, CancellationToken ct = default);
}

public interface IDeliveryService
{
    Task<List<DeliveryDto>> ListAsync(CancellationToken ct = default);
    Task<List<DriverDeliveryDto>> GetMineAsync(Guid userId, CancellationToken ct = default);
    Task<DispatchDeliveriesResult> DispatchAsync(CancellationToken ct = default);
    Task UpdateStatusAsync(Guid userId, bool isDeliveryDriver, Guid deliveryId, DeliveryStatus status, CancellationToken ct = default);
    Task<DeliveryDto> AssignAsync(Guid deliveryId, Guid driverId, CancellationToken ct = default);
}

public interface ICouponService
{
    Task<Coupon> CreateAsync(CreateCouponRequestDto request, CancellationToken ct = default);
    Task<CouponValidationDto> ValidateAsync(string code, decimal orderTotal, CancellationToken ct = default);
}

public interface IReviewService
{
    Task<ReviewDto> CreateAsync(Guid userId, CreateReviewCommand command, CancellationToken ct = default);
}

public interface IDevValidationService
{
    Task<object> ValidateRelationshipsFlowAsync(CancellationToken ct = default);
}
