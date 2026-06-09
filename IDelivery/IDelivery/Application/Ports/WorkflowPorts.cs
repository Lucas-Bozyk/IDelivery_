using IDelivery.Domain;

namespace IDelivery.Application.Ports;

public interface IAuthRepository
{
    Task<bool> EmailExistsAsync(string email, CancellationToken ct = default);
    Task<User?> GetUserByEmailAsync(string email, CancellationToken ct = default);
    Task<User?> GetUserByIdAsync(Guid userId, CancellationToken ct = default);
    Task<List<string>> GetRolesAsync(Guid userId, CancellationToken ct = default);
    Task<Role> GetOrCreateRoleAsync(UserRole role, CancellationToken ct = default);
    Task AddUserAsync(User user, CancellationToken ct = default);
    void UpdateUser(User user);
    void AddUserRole(Guid userId, Guid roleId);
    void AddRefreshToken(RefreshToken refreshToken);
    Task<RefreshToken?> GetRefreshTokenByHashAsync(string tokenHash, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface IAccountProfileRepository
{
    Task<Customer?> GetCustomerByUserIdAsync(Guid userId, CancellationToken ct = default);
    Task<Restaurant?> GetRestaurantByEmailAsync(string email, CancellationToken ct = default);
    Task<RestaurantCategory?> GetFirstRestaurantCategoryAsync(CancellationToken ct = default);
    Task AddCustomerAsync(Customer customer, CancellationToken ct = default);
    Task AddDeliveryDriverAsync(DeliveryDriver driver, CancellationToken ct = default);
    Task AddRestaurantCategoryAsync(RestaurantCategory category, CancellationToken ct = default);
    Task AddRestaurantAsync(Restaurant restaurant, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface ICustomerProfileRepository
{
    Task<Customer?> GetByUserIdAsync(Guid userId, CancellationToken ct = default);
    Task<CustomerAddress?> GetAddressAsync(Guid customerId, Guid addressId, CancellationToken ct = default);
    Task AddAddressAsync(CustomerAddress address, CancellationToken ct = default);
    void RemoveAddress(CustomerAddress address);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface IAddProductToCartRepository
{
    Task<Product?> GetProductAsync(Guid productId, CancellationToken ct = default);
    Task<Cart?> GetActiveCartWithItemsAsync(Guid customerId, CancellationToken ct = default);
    Task<string?> GetRestaurantNameAsync(Guid restaurantId, CancellationToken ct = default);
    Task<CartItem?> GetCartItemAsync(Guid cartId, Guid productId, CancellationToken ct = default);
    Task AddCartAsync(Cart cart, CancellationToken ct = default);
    Task AddCartItemAsync(CartItem item, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface ICreateOrderRepository
{
    Task<CustomerAddress?> GetPreferredAddressAsync(Guid customerId, CancellationToken ct = default);
    Task<Cart?> GetActiveCartWithItemsAsync(Guid customerId, CancellationToken ct = default);
    Task<Restaurant?> GetRestaurantAsync(Guid restaurantId, CancellationToken ct = default);
    Task<List<Product>> GetProductsAsync(IEnumerable<Guid> productIds, CancellationToken ct = default);
    Task<Coupon?> GetCouponAsync(Guid couponId, CancellationToken ct = default);
    Task AddOrderAsync(Order order, CancellationToken ct = default);
    Task AddOrderItemsAsync(IEnumerable<OrderItem> items, CancellationToken ct = default);
    Task AddDeliveryAsync(Delivery delivery, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface ICreateRestaurantRepository
{
    Task AddRestaurantAsync(Restaurant restaurant, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface IReviewRepository
{
    Task<Order?> GetCustomerOrderAsync(Guid customerId, Guid orderId, CancellationToken ct = default);
    Task AddReviewAsync(Review review, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface IDeliveryDispatchRepository
{
    Task<List<Delivery>> GetPendingDeliveriesAsync(CancellationToken ct = default);
    Task<List<DeliveryDriver>> GetDriversAsync(CancellationToken ct = default);
    Task<Dictionary<Guid, int>> GetActiveDeliveryCountsAsync(CancellationToken ct = default);
    Task<int> CountActiveDeliveriesAsync(Guid driverId, CancellationToken ct = default);
    Task<Delivery?> GetDeliveryAsync(Guid deliveryId, CancellationToken ct = default);
    Task<bool> DriverExistsAsync(Guid driverId, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface IOrderStatusRepository
{
    Task<Order?> GetOrderAsync(Guid orderId, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface IPaymentProcessingRepository
{
    Task<Order?> GetOrderAsync(Guid orderId, CancellationToken ct = default);
    Task AddPaymentAsync(Payment payment, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface IRegisterCustomerRepository
{
    Task AddCustomerAsync(Customer customer, CancellationToken ct = default);
    Task SaveChangesAsync(CancellationToken ct = default);
}

public interface IRelationshipValidationPort
{
    Task<object> ExecuteAsync(CancellationToken ct = default);
}
