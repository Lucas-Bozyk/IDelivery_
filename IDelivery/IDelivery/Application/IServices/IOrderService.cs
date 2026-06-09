using IDelivery.Application.DTOs.Orders;
using IDelivery.Application.DTOs.Common;
using IDelivery.Domain;

namespace IDelivery.Application.IServices;

public interface IOrderService
{
    Task<List<OrderDto>> GetByCustomerAsync(Guid customerId, CancellationToken ct = default);
    Task<OrderDto?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<Order> CreateAsync(Guid userId, Guid? couponId, CancellationToken ct = default);
    Task<List<CustomerOrderSummaryDto>> GetByCustomerUserAsync(Guid userId, CancellationToken ct = default);
    Task<OrderDto?> GetCustomerOrderAsync(Guid userId, Guid id, CancellationToken ct = default);
    Task<List<RestaurantOrderSummaryDto>> GetByRestaurantAsync(Guid userId, bool isAdmin, Guid restaurantId, CancellationToken ct = default);
    Task<RestaurantOrderDetailsDto?> GetRestaurantOrderAsync(Guid userId, bool isAdmin, Guid restaurantId, Guid orderId, CancellationToken ct = default);
    Task UpdateStatusAsync(Guid userId, bool isAdmin, Guid orderId, OrderStatus status, CancellationToken ct = default);
    Task<bool> CancelAsync(Guid userId, Guid orderId, CancellationToken ct = default);
}
