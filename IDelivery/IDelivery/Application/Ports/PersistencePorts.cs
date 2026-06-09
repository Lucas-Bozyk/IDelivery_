using IDelivery.Application.DTOs.Carts;
using IDelivery.Application.DTOs.Common;
using IDelivery.Application.DTOs.Deliveries;
using IDelivery.Domain;

namespace IDelivery.Application.Ports;

public interface IIdentityUserReadPort
{
    Task<Guid?> GetRestaurantIdAsync(Guid userId, CancellationToken ct = default);
    Task<Guid?> GetDeliveryDriverIdAsync(Guid userId, CancellationToken ct = default);
}

public interface IRestaurantOwnershipPort
{
    Task<Guid?> GetOwnedRestaurantIdAsync(Guid userId, CancellationToken ct = default);
    Task AssignRestaurantToOwnerAsync(Guid userId, Guid restaurantId, CancellationToken ct = default);
}

public interface ICartRepository
{
    Task<Cart?> GetActiveCartWithItemsAsync(Guid customerId, CancellationToken ct = default);
    Task<CartItem?> GetActiveCartItemAsync(Guid customerId, Guid itemId, CancellationToken ct = default);
    Task LoadItemsAsync(Cart cart, CancellationToken ct = default);
    void RemoveItem(CartItem item);
    void RemoveItems(IEnumerable<CartItem> items);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface ICatalogRepository
{
    Task<List<CategoryDto>> GetMenuCategoriesAsync(CancellationToken ct = default);
    Task<List<CategoryDto>> GetRestaurantCategoriesAsync(CancellationToken ct = default);
}

public interface IPaymentRepository
{
    Task<Payment?> GetPaymentAsync(Guid paymentId, CancellationToken ct = default);
    Task<Order?> GetOrderAsync(Guid orderId, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface ICouponRepository
{
    Task<Coupon?> GetByCodeAsync(string code, CancellationToken ct = default);
    Task AddAsync(Coupon coupon, CancellationToken ct = default);
}

public interface IDeliveryRepository
{
    Task<List<Delivery>> ListAsync(CancellationToken ct = default);
    Task<Delivery?> GetAsync(Guid deliveryId, CancellationToken ct = default);
    Task<Payment?> GetPaymentByOrderAsync(Guid orderId, CancellationToken ct = default);
    Task<Order?> GetOrderAsync(Guid orderId, CancellationToken ct = default);
    Task<List<DriverDeliveryDto>> GetActiveForDriverAsync(Guid driverId, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface IOrderQueryService
{
    Task<Guid?> GetRestaurantIdAsync(Guid orderId, CancellationToken ct = default);
    Task<bool> CustomerOwnsOrderAsync(Guid customerId, Guid orderId, CancellationToken ct = default);
    Task<List<CustomerOrderSummaryDto>> GetByCustomerAsync(Guid customerId, CancellationToken ct = default);
    Task<List<RestaurantOrderSummaryDto>> GetByRestaurantAsync(Guid restaurantId, CancellationToken ct = default);
    Task<RestaurantOrderDetailsDto?> GetRestaurantOrderAsync(Guid restaurantId, Guid orderId, CancellationToken ct = default);
}
