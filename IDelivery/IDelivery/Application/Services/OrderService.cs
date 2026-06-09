using AutoMapper;
using IDelivery.Application.DTOs.Common;
using IDelivery.Application.DTOs.Orders;
using IDelivery.Application.IServices;
using IDelivery.Application.Ports;
using IDelivery.Application.UseCases;
using IDelivery.Domain;
using IDelivery.Domain.Interfaces.IRepositories;

namespace IDelivery.Application.Services;

public class OrderService(
    IOrderRepository orders,
    IOrderQueryService orderQueries,
    IRestaurantOwnershipPort restaurantOwnership,
    ICustomerService customerService,
    CreateOrderUseCase createOrderUseCase,
    DispatchDeliveriesUseCase dispatchDeliveriesUseCase,
    UpdateOrderStatusUseCase updateOrderStatusUseCase,
    IMapper mapper) : IOrderService
{
    public async Task<List<OrderDto>> GetByCustomerAsync(Guid customerId, CancellationToken ct = default) =>
        mapper.Map<List<OrderDto>>(await orders.GetByCustomerAsync(customerId, ct));

    public async Task<OrderDto?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        var o = await orders.GetByIdAsync(id, ct);
        return o is null ? null : mapper.Map<OrderDto>(o);
    }

    public async Task UpdateStatusAsync(Guid userId, bool isAdmin, Guid orderId, OrderStatus status, CancellationToken ct = default)
    {
        var restaurantId = await orderQueries.GetRestaurantIdAsync(orderId, ct);
        if (restaurantId is null) throw new InvalidOperationException("Order not found.");
        await EnsureRestaurantAccessAsync(userId, isAdmin, restaurantId.Value, ct);
        await updateOrderStatusUseCase.ExecuteAsync(new UpdateOrderStatusCommand(orderId, status), ct);
    }

    public async Task<Order> CreateAsync(Guid userId, Guid? couponId, CancellationToken ct = default)
    {
        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        var order = await createOrderUseCase.ExecuteAsync(new CreateOrderCommand(customerId, couponId), ct);
        await dispatchDeliveriesUseCase.ExecuteAsync(ct);
        return order;
    }

    public async Task<List<CustomerOrderSummaryDto>> GetByCustomerUserAsync(Guid userId, CancellationToken ct = default)
    {
        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        return await orderQueries.GetByCustomerAsync(customerId, ct);
    }

    public async Task<OrderDto?> GetCustomerOrderAsync(Guid userId, Guid id, CancellationToken ct = default)
    {
        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        var isOwner = await orderQueries.CustomerOwnsOrderAsync(customerId, id, ct);
        if (!isOwner) return null;
        return await GetByIdAsync(id, ct);
    }

    public async Task<List<RestaurantOrderSummaryDto>> GetByRestaurantAsync(Guid userId, bool isAdmin, Guid restaurantId, CancellationToken ct = default)
    {
        await EnsureRestaurantAccessAsync(userId, isAdmin, restaurantId, ct);
        return await orderQueries.GetByRestaurantAsync(restaurantId, ct);
    }

    public async Task<RestaurantOrderDetailsDto?> GetRestaurantOrderAsync(Guid userId, bool isAdmin, Guid restaurantId, Guid orderId, CancellationToken ct = default)
    {
        await EnsureRestaurantAccessAsync(userId, isAdmin, restaurantId, ct);
        return await orderQueries.GetRestaurantOrderAsync(restaurantId, orderId, ct);
    }

    public async Task<bool> CancelAsync(Guid userId, Guid orderId, CancellationToken ct = default)
    {
        var customerId = await customerService.GetCustomerIdAsync(userId, ct);
        var isOwner = await orderQueries.CustomerOwnsOrderAsync(customerId, orderId, ct);
        if (!isOwner) return false;
        await updateOrderStatusUseCase.ExecuteAsync(new UpdateOrderStatusCommand(orderId, OrderStatus.Cancelled), ct);
        return true;
    }

    private async Task EnsureRestaurantAccessAsync(Guid userId, bool isAdmin, Guid restaurantId, CancellationToken ct)
    {
        if (isAdmin) return;
        var userRestaurantId = await restaurantOwnership.GetOwnedRestaurantIdAsync(userId, ct);
        if (userRestaurantId != restaurantId)
            throw new UnauthorizedAccessException("Restaurant order does not belong to this user.");
    }
}
