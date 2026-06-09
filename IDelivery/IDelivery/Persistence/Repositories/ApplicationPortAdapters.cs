using IDelivery.Application.DTOs.Common;
using IDelivery.Application.DTOs.Deliveries;
using IDelivery.Application.Ports;
using IDelivery.Domain;
using Microsoft.EntityFrameworkCore;

namespace IDelivery.Persistence.Repositories;

public class IdentityUserPort(IdentityDbContext db) : IIdentityUserReadPort, IRestaurantOwnershipPort
{
    public Task<Guid?> GetRestaurantIdAsync(Guid userId, CancellationToken ct = default) =>
        db.Users.Where(x => x.Id == userId).Select(x => x.RestaurantId).FirstOrDefaultAsync(ct);

    public Task<Guid?> GetDeliveryDriverIdAsync(Guid userId, CancellationToken ct = default) =>
        db.Users.Where(x => x.Id == userId).Select(x => x.DeliveryDriverId).FirstOrDefaultAsync(ct);

    public Task<Guid?> GetOwnedRestaurantIdAsync(Guid userId, CancellationToken ct = default) =>
        GetRestaurantIdAsync(userId, ct);

    public async Task AssignRestaurantToOwnerAsync(Guid userId, Guid restaurantId, CancellationToken ct = default)
    {
        var user = await db.Users.FirstOrDefaultAsync(x => x.Id == userId, ct)
            ?? throw new InvalidOperationException("User not found.");
        user.RestaurantId = restaurantId;
        db.Users.Update(user);
        await db.SaveChangesAsync(ct);
    }
}

public class CartRepositoryPort(DeliveryDbContext db) : ICartRepository
{
    public Task<Cart?> GetActiveCartWithItemsAsync(Guid customerId, CancellationToken ct = default) =>
        db.Carts.Include(x => x.Items).FirstOrDefaultAsync(x => x.CustomerId == customerId && x.IsActive, ct);

    public Task<CartItem?> GetActiveCartItemAsync(Guid customerId, Guid itemId, CancellationToken ct = default) =>
        db.CartItems
            .Join(db.Carts, i => i.CartId, c => c.Id, (i, c) => new { i, c })
            .Where(x => x.i.Id == itemId && x.c.CustomerId == customerId && x.c.IsActive)
            .Select(x => x.i)
            .FirstOrDefaultAsync(ct);

    public Task LoadItemsAsync(Cart cart, CancellationToken ct = default) =>
        db.Entry(cart).Collection(x => x.Items).LoadAsync(ct);

    public void RemoveItem(CartItem item) => db.CartItems.Remove(item);

    public void RemoveItems(IEnumerable<CartItem> items) => db.CartItems.RemoveRange(items);

    public async Task SaveChangesAsync(CancellationToken ct = default) => await db.SaveChangesAsync(ct);
}

public class CatalogRepositoryPort(DeliveryDbContext db) : ICatalogRepository
{
    public Task<List<CategoryDto>> GetMenuCategoriesAsync(CancellationToken ct = default) =>
        db.MenuCategories.OrderBy(x => x.Name).Select(x => new CategoryDto(x.Id, x.Name)).ToListAsync(ct);

    public Task<List<CategoryDto>> GetRestaurantCategoriesAsync(CancellationToken ct = default) =>
        db.RestaurantCategories.OrderBy(x => x.Name).Select(x => new CategoryDto(x.Id, x.Name)).ToListAsync(ct);
}

public class PaymentRepositoryPort(DeliveryDbContext db) : IPaymentRepository
{
    public Task<Payment?> GetPaymentAsync(Guid paymentId, CancellationToken ct = default) =>
        db.Payments.FirstOrDefaultAsync(x => x.Id == paymentId, ct);

    public Task<Order?> GetOrderAsync(Guid orderId, CancellationToken ct = default) =>
        db.Orders.FirstOrDefaultAsync(x => x.Id == orderId, ct);

    public async Task SaveChangesAsync(CancellationToken ct = default) => await db.SaveChangesAsync(ct);
}

public class CouponRepositoryPort(DeliveryDbContext db) : ICouponRepository
{
    public Task<Coupon?> GetByCodeAsync(string code, CancellationToken ct = default) =>
        db.Coupons.FirstOrDefaultAsync(x => x.Code == code, ct);

    public async Task AddAsync(Coupon coupon, CancellationToken ct = default) =>
        await db.Coupons.AddAsync(coupon, ct);
}

public class DeliveryRepositoryPort(DeliveryDbContext db) : IDeliveryRepository
{
    public Task<List<Delivery>> ListAsync(CancellationToken ct = default) =>
        db.Deliveries.ToListAsync(ct);

    public Task<Delivery?> GetAsync(Guid deliveryId, CancellationToken ct = default) =>
        db.Deliveries.FirstOrDefaultAsync(x => x.Id == deliveryId, ct);

    public Task<Payment?> GetPaymentByOrderAsync(Guid orderId, CancellationToken ct = default) =>
        db.Payments.FirstOrDefaultAsync(x => x.OrderId == orderId, ct);

    public Task<Order?> GetOrderAsync(Guid orderId, CancellationToken ct = default) =>
        db.Orders.FirstOrDefaultAsync(x => x.Id == orderId, ct);

    public Task<List<DriverDeliveryDto>> GetActiveForDriverAsync(Guid driverId, CancellationToken ct = default) =>
        (
            from delivery in db.Deliveries
            join order in db.Orders on delivery.OrderId equals order.Id
            join restaurant in db.Restaurants on order.RestaurantId equals restaurant.Id
            where delivery.DeliveryDriverId == driverId
                && delivery.Status != DeliveryStatus.Delivered
                && delivery.Status != DeliveryStatus.Cancelled
            orderby delivery.CreatedAt
            select new DriverDeliveryDto(
                delivery.Id,
                delivery.OrderId,
                delivery.DeliveryDriverId,
                delivery.Status,
                delivery.AddressSnapshot,
                delivery.EstimatedDeliveryTime,
                delivery.DeliveredAt,
                delivery.CreatedAt,
                restaurant.Id,
                restaurant.Name))
        .ToListAsync(ct);

    public async Task SaveChangesAsync(CancellationToken ct = default) => await db.SaveChangesAsync(ct);
}

public class OrderQueryService(DeliveryDbContext db) : IOrderQueryService
{
    public Task<Guid?> GetRestaurantIdAsync(Guid orderId, CancellationToken ct = default) =>
        db.Orders.Where(x => x.Id == orderId).Select(x => (Guid?)x.RestaurantId).FirstOrDefaultAsync(ct);

    public Task<bool> CustomerOwnsOrderAsync(Guid customerId, Guid orderId, CancellationToken ct = default) =>
        db.Orders.AnyAsync(x => x.Id == orderId && x.CustomerId == customerId, ct);

    public Task<List<CustomerOrderSummaryDto>> GetByCustomerAsync(Guid customerId, CancellationToken ct = default) =>
        (
            from order in db.Orders
            join restaurant in db.Restaurants on order.RestaurantId equals restaurant.Id
            where order.CustomerId == customerId
            orderby order.CreatedAt descending
            select new CustomerOrderSummaryDto(
                order.Id,
                order.CustomerId,
                order.RestaurantId,
                restaurant.Name,
                order.Status,
                order.Subtotal,
                order.DeliveryFee,
                order.Discount,
                order.Total,
                order.CreatedAt,
                order.ConfirmedAt,
                order.CancelledAt,
                order.CompletedAt))
        .ToListAsync(ct);

    public Task<List<RestaurantOrderSummaryDto>> GetByRestaurantAsync(Guid restaurantId, CancellationToken ct = default) =>
        db.Orders
            .Where(x => x.RestaurantId == restaurantId)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new RestaurantOrderSummaryDto(x.Id, x.Status, x.Total, x.Subtotal, x.DeliveryFee, x.Discount, x.CreatedAt))
            .ToListAsync(ct);

    public async Task<RestaurantOrderDetailsDto?> GetRestaurantOrderAsync(Guid restaurantId, Guid orderId, CancellationToken ct = default)
    {
        var order = await db.Orders
            .Where(x => x.Id == orderId && x.RestaurantId == restaurantId)
            .Select(x => new RestaurantOrderSummaryDto(x.Id, x.Status, x.Total, x.Subtotal, x.DeliveryFee, x.Discount, x.CreatedAt))
            .FirstOrDefaultAsync(ct);
        if (order is null) return null;

        var items = await db.OrderItems
            .Where(x => x.OrderId == orderId)
            .OrderBy(x => x.ProductName)
            .Select(x => new RestaurantOrderItemDto(x.Id, x.ProductId, x.ProductName, x.UnitPrice, x.Quantity, x.TotalPrice, x.Observation))
            .ToListAsync(ct);

        return new RestaurantOrderDetailsDto(order, items);
    }
}
