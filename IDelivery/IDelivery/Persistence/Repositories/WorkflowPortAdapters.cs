using IDelivery.Application.Ports;
using IDelivery.Domain;
using Microsoft.EntityFrameworkCore;

namespace IDelivery.Persistence.Repositories;

public class AuthRepositoryPort(IdentityDbContext db) : IAuthRepository
{
    public Task<bool> EmailExistsAsync(string email, CancellationToken ct = default) =>
        db.Users.AnyAsync(x => x.Email == email, ct);

    public Task<User?> GetUserByEmailAsync(string email, CancellationToken ct = default) =>
        db.Users.FirstOrDefaultAsync(x => x.Email == email, ct);

    public Task<User?> GetUserByIdAsync(Guid userId, CancellationToken ct = default) =>
        db.Users.FirstOrDefaultAsync(x => x.Id == userId, ct);

    public Task<List<string>> GetRolesAsync(Guid userId, CancellationToken ct = default) =>
        db.UserRoles
            .Where(x => x.UserId == userId)
            .Join(db.Roles, ur => ur.RoleId, r => r.Id, (_, r) => r.Name.ToString())
            .ToListAsync(ct);

    public async Task<Role> GetOrCreateRoleAsync(UserRole role, CancellationToken ct = default)
    {
        var entity = await db.Roles.FirstOrDefaultAsync(x => x.Name == role, ct);
        if (entity is not null) return entity;
        entity = new Role { Name = role };
        db.Roles.Add(entity);
        await db.SaveChangesAsync(ct);
        return entity;
    }

    public async Task AddUserAsync(User user, CancellationToken ct = default) =>
        await db.Users.AddAsync(user, ct);

    public void UpdateUser(User user) => db.Users.Update(user);

    public void AddUserRole(Guid userId, Guid roleId) =>
        db.UserRoles.Add(new UserRoleMap { UserId = userId, RoleId = roleId });

    public void AddRefreshToken(RefreshToken refreshToken) => db.RefreshTokens.Add(refreshToken);

    public Task<RefreshToken?> GetRefreshTokenByHashAsync(string tokenHash, CancellationToken ct = default) =>
        db.RefreshTokens.FirstOrDefaultAsync(x => x.Token == tokenHash, ct);

    public async Task SaveChangesAsync(CancellationToken ct = default) => await db.SaveChangesAsync(ct);
}

public class AccountProfileRepositoryPort(DeliveryDbContext db) : IAccountProfileRepository
{
    public Task<Customer?> GetCustomerByUserIdAsync(Guid userId, CancellationToken ct = default) =>
        db.Customers.FirstOrDefaultAsync(x => x.UserId == userId, ct);

    public Task<Restaurant?> GetRestaurantByEmailAsync(string email, CancellationToken ct = default) =>
        db.Restaurants.FirstOrDefaultAsync(x => x.Email == email, ct);

    public Task<RestaurantCategory?> GetFirstRestaurantCategoryAsync(CancellationToken ct = default) =>
        db.RestaurantCategories.OrderBy(x => x.Name).FirstOrDefaultAsync(ct);

    public async Task AddCustomerAsync(Customer customer, CancellationToken ct = default) =>
        await db.Customers.AddAsync(customer, ct);

    public async Task AddDeliveryDriverAsync(DeliveryDriver driver, CancellationToken ct = default) =>
        await db.DeliveryDrivers.AddAsync(driver, ct);

    public async Task AddRestaurantCategoryAsync(RestaurantCategory category, CancellationToken ct = default) =>
        await db.RestaurantCategories.AddAsync(category, ct);

    public async Task AddRestaurantAsync(Restaurant restaurant, CancellationToken ct = default) =>
        await db.Restaurants.AddAsync(restaurant, ct);

    public async Task SaveChangesAsync(CancellationToken ct = default) => await db.SaveChangesAsync(ct);
}

public class CustomerProfileRepositoryPort(DeliveryDbContext db) : ICustomerProfileRepository
{
    public Task<Customer?> GetByUserIdAsync(Guid userId, CancellationToken ct = default) =>
        db.Customers.FirstOrDefaultAsync(x => x.UserId == userId, ct);

    public Task<CustomerAddress?> GetAddressAsync(Guid customerId, Guid addressId, CancellationToken ct = default) =>
        db.CustomerAddresses.FirstOrDefaultAsync(x => x.Id == addressId && x.CustomerId == customerId, ct);

    public async Task AddAddressAsync(CustomerAddress address, CancellationToken ct = default) =>
        await db.CustomerAddresses.AddAsync(address, ct);

    public void RemoveAddress(CustomerAddress address) => db.CustomerAddresses.Remove(address);

    public async Task SaveChangesAsync(CancellationToken ct = default) => await db.SaveChangesAsync(ct);
}

public class CartWorkflowRepositoryPort(DeliveryDbContext db) : IAddProductToCartRepository
{
    public Task<Product?> GetProductAsync(Guid productId, CancellationToken ct = default) =>
        db.Products.FirstOrDefaultAsync(x => x.Id == productId, ct);

    public Task<Cart?> GetActiveCartWithItemsAsync(Guid customerId, CancellationToken ct = default) =>
        db.Carts.Include(x => x.Items).FirstOrDefaultAsync(x => x.CustomerId == customerId && x.IsActive, ct);

    public Task<string?> GetRestaurantNameAsync(Guid restaurantId, CancellationToken ct = default) =>
        db.Restaurants.Where(x => x.Id == restaurantId).Select(x => x.Name).FirstOrDefaultAsync(ct);

    public Task<CartItem?> GetCartItemAsync(Guid cartId, Guid productId, CancellationToken ct = default) =>
        db.CartItems.FirstOrDefaultAsync(x => x.CartId == cartId && x.ProductId == productId, ct);

    public async Task AddCartAsync(Cart cart, CancellationToken ct = default) =>
        await db.Carts.AddAsync(cart, ct);

    public async Task AddCartItemAsync(CartItem item, CancellationToken ct = default) =>
        await db.CartItems.AddAsync(item, ct);

    public async Task SaveChangesAsync(CancellationToken ct = default) => await db.SaveChangesAsync(ct);
}

public class OrderWorkflowRepositoryPort(DeliveryDbContext db) : ICreateOrderRepository, IOrderStatusRepository, IPaymentProcessingRepository, IReviewRepository, IRegisterCustomerRepository, ICreateRestaurantRepository
{
    public Task<CustomerAddress?> GetPreferredAddressAsync(Guid customerId, CancellationToken ct = default) =>
        db.CustomerAddresses
            .Where(x => x.CustomerId == customerId)
            .OrderByDescending(x => x.IsDefault)
            .ThenByDescending(x => x.Id)
            .FirstOrDefaultAsync(ct);

    public Task<Cart?> GetActiveCartWithItemsAsync(Guid customerId, CancellationToken ct = default) =>
        db.Carts.Include(x => x.Items).FirstOrDefaultAsync(x => x.CustomerId == customerId && x.IsActive, ct);

    public Task<Restaurant?> GetRestaurantAsync(Guid restaurantId, CancellationToken ct = default) =>
        db.Restaurants.FirstOrDefaultAsync(x => x.Id == restaurantId, ct);

    public Task<List<Product>> GetProductsAsync(IEnumerable<Guid> productIds, CancellationToken ct = default)
    {
        var ids = productIds.Distinct().ToList();
        return db.Products.Where(x => ids.Contains(x.Id)).ToListAsync(ct);
    }

    public Task<Coupon?> GetCouponAsync(Guid couponId, CancellationToken ct = default) =>
        db.Coupons.FirstOrDefaultAsync(x => x.Id == couponId, ct);

    public async Task AddOrderAsync(Order order, CancellationToken ct = default) =>
        await db.Orders.AddAsync(order, ct);

    public async Task AddOrderItemsAsync(IEnumerable<OrderItem> items, CancellationToken ct = default) =>
        await db.OrderItems.AddRangeAsync(items, ct);

    public async Task AddDeliveryAsync(Delivery delivery, CancellationToken ct = default) =>
        await db.Deliveries.AddAsync(delivery, ct);

    public Task<Order?> GetOrderAsync(Guid orderId, CancellationToken ct = default) =>
        db.Orders.FirstOrDefaultAsync(x => x.Id == orderId, ct);

    public async Task AddPaymentAsync(Payment payment, CancellationToken ct = default) =>
        await db.Payments.AddAsync(payment, ct);

    public Task<Order?> GetCustomerOrderAsync(Guid customerId, Guid orderId, CancellationToken ct = default) =>
        db.Orders.FirstOrDefaultAsync(x => x.Id == orderId && x.CustomerId == customerId, ct);

    public async Task AddReviewAsync(Review review, CancellationToken ct = default) =>
        await db.Reviews.AddAsync(review, ct);

    public async Task AddCustomerAsync(Customer customer, CancellationToken ct = default) =>
        await db.Customers.AddAsync(customer, ct);

    public async Task AddRestaurantAsync(Restaurant restaurant, CancellationToken ct = default) =>
        await db.Restaurants.AddAsync(restaurant, ct);

    public async Task SaveChangesAsync(CancellationToken ct = default) => await db.SaveChangesAsync(ct);
}

public class DeliveryDispatchRepositoryPort(DeliveryDbContext db) : IDeliveryDispatchRepository
{
    private static readonly DeliveryStatus[] ActiveStatuses =
    [
        DeliveryStatus.Assigned,
        DeliveryStatus.PickedUp
    ];

    public Task<List<Delivery>> GetPendingDeliveriesAsync(CancellationToken ct = default) =>
        db.Deliveries
            .Where(x => x.Status == DeliveryStatus.Pending && x.DeliveryDriverId == null)
            .OrderBy(x => x.CreatedAt)
            .ToListAsync(ct);

    public Task<List<DeliveryDriver>> GetDriversAsync(CancellationToken ct = default) =>
        db.DeliveryDrivers.OrderBy(x => x.Name).ToListAsync(ct);

    public Task<Dictionary<Guid, int>> GetActiveDeliveryCountsAsync(CancellationToken ct = default) =>
        db.Deliveries
            .Where(x => x.DeliveryDriverId.HasValue && ActiveStatuses.Contains(x.Status))
            .GroupBy(x => x.DeliveryDriverId!.Value)
            .Select(x => new { DriverId = x.Key, ActiveCount = x.Count() })
            .ToDictionaryAsync(x => x.DriverId, x => x.ActiveCount, ct);

    public Task<int> CountActiveDeliveriesAsync(Guid driverId, CancellationToken ct = default) =>
        db.Deliveries.CountAsync(x => x.DeliveryDriverId == driverId && ActiveStatuses.Contains(x.Status), ct);

    public Task<Delivery?> GetDeliveryAsync(Guid deliveryId, CancellationToken ct = default) =>
        db.Deliveries.FirstOrDefaultAsync(x => x.Id == deliveryId, ct);

    public Task<bool> DriverExistsAsync(Guid driverId, CancellationToken ct = default) =>
        db.DeliveryDrivers.AnyAsync(x => x.Id == driverId, ct);

    public async Task SaveChangesAsync(CancellationToken ct = default) => await db.SaveChangesAsync(ct);
}

public class RelationshipValidationPort(DeliveryDbContext db) : IRelationshipValidationPort
{
    public async Task<object> ExecuteAsync(CancellationToken ct = default)
    {
        var suffix = DateTime.UtcNow.Ticks.ToString();

        var category = new RestaurantCategory { Name = $"Categoria {suffix}" };
        db.RestaurantCategories.Add(category);

        var restaurant = new Restaurant
        {
            Name = $"Rest {suffix}",
            Description = "validacao",
            Cnpj = "12345678000199",
            Phone = "11999999999",
            Email = $"rest{suffix}@local.test",
            CategoryId = category.Id,
            IsOpen = true
        };
        db.Restaurants.Add(restaurant);

        var menu = new MenuCategory { Name = "Lanches" };
        db.MenuCategories.Add(menu);

        var product = new Product
        {
            RestaurantId = restaurant.Id,
            MenuCategoryId = menu.Id,
            Name = "Burger",
            Description = "ok",
            Price = 20,
            IsAvailable = true
        };
        db.Products.Add(product);

        var customer = new Customer { UserId = Guid.NewGuid(), FullName = "Flow User", Phone = "11999999999" };
        db.Customers.Add(customer);
        db.CustomerAddresses.Add(new CustomerAddress
        {
            CustomerId = customer.Id,
            Street = "Rua A",
            Number = "10",
            Neighborhood = "Centro",
            City = "SP",
            State = "SP",
            ZipCode = "01001000"
        });
        var driver = new DeliveryDriver { Name = "Moto Teste" };
        db.DeliveryDrivers.Add(driver);
        await db.SaveChangesAsync(ct);

        var cart = new Cart { CustomerId = customer.Id, RestaurantId = restaurant.Id };
        db.Carts.Add(cart);
        db.CartItems.Add(new CartItem { CartId = cart.Id, ProductId = product.Id, Quantity = 2 });
        await db.SaveChangesAsync(ct);

        var order = Order.Create(customer.Id, restaurant.Id, 40, 8, 0);
        order.ConfirmPayment();
        db.Orders.Add(order);
        db.OrderItems.Add(new OrderItem
        {
            OrderId = order.Id,
            ProductId = product.Id,
            ProductName = product.Name,
            UnitPrice = 20,
            Quantity = 2,
            TotalPrice = 40
        });
        var payment = Payment.Create(order.Id, PaymentMethod.Pix, order.Total, true);
        db.Payments.Add(payment);
        var delivery = new Delivery
        {
            OrderId = order.Id,
            AddressSnapshot = "Rua A, 10",
            EstimatedDeliveryTime = DateTime.UtcNow.AddMinutes(30)
        };
        delivery.AssignDriver(driver.Id);
        delivery.UpdateStatus(DeliveryStatus.Delivered, true);
        order.UpdateStatus(OrderStatus.Completed);
        db.Deliveries.Add(delivery);
        var review = Review.Create(customer.Id, order, 5, "fluxo ok");
        db.Reviews.Add(review);
        cart.IsActive = false;
        await db.SaveChangesAsync(ct);

        return new
        {
            restaurantId = restaurant.Id,
            productId = product.Id,
            orderId = order.Id,
            paymentId = payment.Id,
            deliveryId = delivery.Id,
            reviewId = review.Id
        };
    }
}
