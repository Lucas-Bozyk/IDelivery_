using System.Security.Cryptography;
using System.Text;
using AutoMapper;
using IDelivery.Application.DTOs.Carts;
using IDelivery.Application.DTOs.Common;
using IDelivery.Application.DTOs.Coupons;
using IDelivery.Application.DTOs.Deliveries;
using IDelivery.Application.DTOs.Payments;
using IDelivery.Application.DTOs.Reviews;
using IDelivery.Application.IServices;
using IDelivery.Application.Ports;
using IDelivery.Application.UseCases;
using IDelivery.Domain;
using IDelivery.Domain.Interfaces.IRepositories;
using Microsoft.Extensions.Configuration;

namespace IDelivery.Application.Services;

public class CatalogService(ICatalogRepository catalog) : ICatalogService
{
    public Task<List<CategoryDto>> GetMenuCategoriesAsync(CancellationToken ct = default) =>
        catalog.GetMenuCategoriesAsync(ct);

    public Task<List<CategoryDto>> GetRestaurantCategoriesAsync(CancellationToken ct = default) =>
        catalog.GetRestaurantCategoriesAsync(ct);
}

public class CartService(
    ICartRepository carts,
    ICustomerService customerService,
    AddProductToCartUseCase addProductToCartUseCase,
    IMapper mapper) : ICartService
{
    public async Task<CartDto?> GetActiveCartAsync(Guid userId, CancellationToken ct = default)
    {
        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        var cart = await carts.GetActiveCartWithItemsAsync(customerId, ct);
        return cart is null ? null : mapper.Map<CartDto>(cart);
    }

    public async Task<CartDto> AddItemAsync(Guid userId, AddProductToCartCommand command, CancellationToken ct = default)
    {
        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        var cart = await addProductToCartUseCase.ExecuteAsync(command with { CustomerId = customerId }, ct);
        await carts.LoadItemsAsync(cart, ct);
        return mapper.Map<CartDto>(cart);
    }

    public async Task<bool> UpdateItemAsync(Guid userId, Guid itemId, int quantity, CancellationToken ct = default)
    {
        if (quantity <= 0) throw new InvalidOperationException("Quantidade deve ser maior que zero.");

        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        var item = await carts.GetActiveCartItemAsync(customerId, itemId, ct);
        if (item is null) return false;
        item.Quantity = quantity;
        await carts.SaveChangesAsync(ct);
        return true;
    }

    public async Task<bool> RemoveItemAsync(Guid userId, Guid itemId, CancellationToken ct = default)
    {
        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        var item = await carts.GetActiveCartItemAsync(customerId, itemId, ct);
        if (item is null) return false;
        carts.RemoveItem(item);
        await carts.SaveChangesAsync(ct);
        return true;
    }

    public async Task ClearAsync(Guid userId, CancellationToken ct = default)
    {
        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        var cart = await carts.GetActiveCartWithItemsAsync(customerId, ct);
        if (cart is null) return;
        carts.RemoveItems(cart.Items);
        await carts.SaveChangesAsync(ct);
    }
}

public class PaymentService(
    IPaymentRepository payments,
    ProcessPaymentUseCase processPaymentUseCase,
    IConfiguration configuration,
    ICustomerService customerService,
    IMapper mapper) : IPaymentService
{
    public async Task<PaymentDto> CreateAsync(Guid userId, ProcessPaymentRequestDto request, CancellationToken ct = default)
    {
        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        var command = new ProcessPaymentCommand(customerId, request.OrderId, request.Method);
        var payment = await processPaymentUseCase.ExecuteAsync(command, ct);
        return mapper.Map<PaymentDto>(payment);
    }

    public async Task ProcessWebhookAsync(Guid paymentId, string? providedSignature, CancellationToken ct = default)
    {
        var secret = configuration["Payments:WebhookSecret"] ?? configuration["Payments__WebhookSecret"];
        if (string.IsNullOrWhiteSpace(secret)) throw new InvalidOperationException("Payments webhook secret not configured.");
        if (string.IsNullOrWhiteSpace(providedSignature)) throw new UnauthorizedAccessException("Missing webhook signature.");

        var expectedSignature = ComputeHmac(paymentId.ToString("N"), secret);
        if (!CryptographicOperations.FixedTimeEquals(
                Encoding.UTF8.GetBytes(providedSignature),
                Encoding.UTF8.GetBytes(expectedSignature)))
            throw new UnauthorizedAccessException("Invalid webhook signature.");

        var payment = await payments.GetPaymentAsync(paymentId, ct)
            ?? throw new InvalidOperationException("Payment not found.");
        if (payment.Status == PaymentStatus.Approved)
        {
            var order = await payments.GetOrderAsync(payment.OrderId, ct)
                ?? throw new InvalidOperationException("Order not found.");
            order.Status = OrderStatus.Confirmed;
            await payments.SaveChangesAsync(ct);
        }
    }

    private static string ComputeHmac(string payload, string secret)
    {
        using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secret));
        var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(payload));
        return Convert.ToHexString(hash).ToLowerInvariant();
    }
}

public class DeliveryService(
    IDeliveryRepository deliveries,
    IIdentityUserReadPort identityUsers,
    AssignDeliveryDriverUseCase assignDeliveryDriverUseCase,
    DispatchDeliveriesUseCase dispatchDeliveriesUseCase,
    IMapper mapper) : IDeliveryService
{
    public async Task<List<DeliveryDto>> ListAsync(CancellationToken ct = default) =>
        mapper.Map<List<DeliveryDto>>(await deliveries.ListAsync(ct));

    public async Task<List<DriverDeliveryDto>> GetMineAsync(Guid userId, CancellationToken ct = default)
    {
        var driverId = await identityUsers.GetDeliveryDriverIdAsync(userId, ct);
        if (driverId is null) throw new InvalidOperationException("Delivery driver profile not found.");

        return await deliveries.GetActiveForDriverAsync(driverId.Value, ct);
    }

    public Task<DispatchDeliveriesResult> DispatchAsync(CancellationToken ct = default) =>
        dispatchDeliveriesUseCase.ExecuteAsync(ct);

    public async Task UpdateStatusAsync(Guid userId, bool isDeliveryDriver, Guid deliveryId, DeliveryStatus status, CancellationToken ct = default)
    {
        var delivery = await deliveries.GetAsync(deliveryId, ct)
            ?? throw new InvalidOperationException("Delivery not found.");
        if (isDeliveryDriver)
        {
            var driverId = await identityUsers.GetDeliveryDriverIdAsync(userId, ct);
            if (driverId is null || delivery.DeliveryDriverId != driverId.Value)
                throw new UnauthorizedAccessException("Delivery does not belong to this driver.");
        }

        var payment = await deliveries.GetPaymentByOrderAsync(delivery.OrderId, ct);
        var canCompleteDelivery = payment is null || payment.Status == PaymentStatus.Approved;
        delivery.UpdateStatus(status, canCompleteDelivery);
        if (status == DeliveryStatus.Delivered)
        {
            var order = await deliveries.GetOrderAsync(delivery.OrderId, ct);
            order?.UpdateStatus(OrderStatus.Completed);
        }
        await deliveries.SaveChangesAsync(ct);
    }

    public async Task<DeliveryDto> AssignAsync(Guid deliveryId, Guid driverId, CancellationToken ct = default)
    {
        var delivery = await assignDeliveryDriverUseCase.ExecuteAsync(new AssignDeliveryDriverCommand(deliveryId, driverId), ct);
        return mapper.Map<DeliveryDto>(delivery);
    }
}

public class CouponService(ICouponRepository coupons, IUnitOfWork unitOfWork) : ICouponService
{
    public async Task<Coupon> CreateAsync(CreateCouponRequestDto request, CancellationToken ct = default)
    {
        if (request.DiscountType == DiscountType.Percentage && request.Value > 100)
            throw new InvalidOperationException("Percentage coupon value cannot be greater than 100.");

        var coupon = new Coupon
        {
            Code = request.Code.Trim().ToUpperInvariant(),
            DiscountType = request.DiscountType,
            Value = request.Value,
            MinValue = request.MinValue,
            ExpirationDate = request.ExpirationDate,
            UsageLimit = request.UsageLimit
        };
        await coupons.AddAsync(coupon, ct);
        await unitOfWork.SaveChangesAsync(ct);
        return coupon;
    }

    public async Task<CouponValidationDto> ValidateAsync(string code, decimal orderTotal, CancellationToken ct = default)
    {
        var normalizedCode = code.Trim().ToUpperInvariant();
        var coupon = await coupons.GetByCodeAsync(normalizedCode, ct);
        if (coupon is null) return new CouponValidationDto(code, false);
        var valid = coupon.ExpirationDate >= DateTime.UtcNow && orderTotal >= coupon.MinValue && coupon.UsedCount < coupon.UsageLimit;
        return new CouponValidationDto(code, valid);
    }
}

public class ReviewService(ICustomerService customerService, CreateReviewUseCase createReviewUseCase, IMapper mapper) : IReviewService
{
    public async Task<ReviewDto> CreateAsync(Guid userId, CreateReviewCommand command, CancellationToken ct = default)
    {
        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        var review = await createReviewUseCase.ExecuteAsync(command with { CustomerId = customerId }, ct);
        return mapper.Map<ReviewDto>(review);
    }
}

public class DevValidationService(ValidateRelationshipsFlowUseCase validator) : IDevValidationService
{
    public Task<object> ValidateRelationshipsFlowAsync(CancellationToken ct = default) =>
        validator.ExecuteAsync(ct);
}
