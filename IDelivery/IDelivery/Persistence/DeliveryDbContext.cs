using IDelivery.Domain;
using Microsoft.EntityFrameworkCore;

namespace IDelivery.Persistence;

public class DeliveryDbContext(DbContextOptions<DeliveryDbContext> options) : DbContext(options)
{
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<CustomerAddress> CustomerAddresses => Set<CustomerAddress>();
    public DbSet<Restaurant> Restaurants => Set<Restaurant>();
    public DbSet<RestaurantCategory> RestaurantCategories => Set<RestaurantCategory>();
    public DbSet<MenuCategory> MenuCategories => Set<MenuCategory>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<ProductOptionGroup> ProductOptionGroups => Set<ProductOptionGroup>();
    public DbSet<ProductOption> ProductOptions => Set<ProductOption>();
    public DbSet<Cart> Carts => Set<Cart>();
    public DbSet<CartItem> CartItems => Set<CartItem>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<Delivery> Deliveries => Set<Delivery>();
    public DbSet<DeliveryDriver> DeliveryDrivers => Set<DeliveryDriver>();
    public DbSet<Coupon> Coupons => Set<Coupon>();
    public DbSet<Review> Reviews => Set<Review>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<CustomerAddress>()
            .HasOne<Customer>()
            .WithMany(x => x.Addresses)
            .HasForeignKey(x => x.CustomerId);

        modelBuilder.Entity<Restaurant>()
            .HasOne<RestaurantCategory>()
            .WithMany()
            .HasForeignKey(x => x.CategoryId);

        modelBuilder.Entity<Product>()
            .HasOne<Restaurant>()
            .WithMany()
            .HasForeignKey(x => x.RestaurantId);
        modelBuilder.Entity<Product>()
            .HasOne<MenuCategory>()
            .WithMany()
            .HasForeignKey(x => x.MenuCategoryId);

        modelBuilder.Entity<ProductOptionGroup>()
            .HasOne<Product>()
            .WithMany(x => x.OptionGroups)
            .HasForeignKey(x => x.ProductId);
        modelBuilder.Entity<ProductOption>()
            .HasOne<ProductOptionGroup>()
            .WithMany(x => x.Options)
            .HasForeignKey(x => x.ProductOptionGroupId);

        modelBuilder.Entity<CartItem>()
            .HasOne<Cart>()
            .WithMany(x => x.Items)
            .HasForeignKey(x => x.CartId);

        modelBuilder.Entity<Order>()
            .HasOne<Customer>()
            .WithMany()
            .HasForeignKey(x => x.CustomerId);
        modelBuilder.Entity<Order>()
            .HasOne<Restaurant>()
            .WithMany()
            .HasForeignKey(x => x.RestaurantId);

        modelBuilder.Entity<OrderItem>()
            .HasOne<Order>()
            .WithMany()
            .HasForeignKey(x => x.OrderId);

        modelBuilder.Entity<Payment>()
            .HasOne<Order>()
            .WithOne()
            .HasForeignKey<Payment>(x => x.OrderId);

        modelBuilder.Entity<Delivery>()
            .HasOne<Order>()
            .WithOne()
            .HasForeignKey<Delivery>(x => x.OrderId);
        modelBuilder.Entity<Delivery>()
            .HasOne<DeliveryDriver>()
            .WithMany()
            .HasForeignKey(x => x.DeliveryDriverId);

        modelBuilder.Entity<Review>()
            .HasOne<Customer>()
            .WithMany()
            .HasForeignKey(x => x.CustomerId);
        modelBuilder.Entity<Review>()
            .HasOne<Restaurant>()
            .WithMany()
            .HasForeignKey(x => x.RestaurantId);
        modelBuilder.Entity<Review>()
            .HasOne<Order>()
            .WithOne()
            .HasForeignKey<Review>(x => x.OrderId);

        modelBuilder.Entity<MenuCategory>().HasData(
            new MenuCategory { Id = Guid.Parse("11111111-1111-1111-1111-111111111111"), Name = "Japonesa" },
            new MenuCategory { Id = Guid.Parse("22222222-2222-2222-2222-222222222222"), Name = "Lanches" },
            new MenuCategory { Id = Guid.Parse("33333333-3333-3333-3333-333333333333"), Name = "Pizza" },
            new MenuCategory { Id = Guid.Parse("44444444-4444-4444-4444-444444444444"), Name = "Brasileira" },
            new MenuCategory { Id = Guid.Parse("55555555-5555-5555-5555-555555555555"), Name = "Saudavel" },
            new MenuCategory { Id = Guid.Parse("66666666-6666-6666-6666-666666666666"), Name = "Sobremesa" },
            new MenuCategory { Id = Guid.Parse("77777777-7777-7777-7777-777777777777"), Name = "Italiana" },
            new MenuCategory { Id = Guid.Parse("88888888-8888-8888-8888-888888888888"), Name = "Mexicana" },
            new MenuCategory { Id = Guid.Parse("99999999-9999-9999-9999-999999999999"), Name = "Arabe" },
            new MenuCategory { Id = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), Name = "Chinesa" },
            new MenuCategory { Id = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), Name = "Indiana" },
            new MenuCategory { Id = Guid.Parse("cccccccc-cccc-cccc-cccc-cccccccccccc"), Name = "Massas" },
            new MenuCategory { Id = Guid.Parse("dddddddd-dddd-dddd-dddd-dddddddddddd"), Name = "Frutos do Mar" },
            new MenuCategory { Id = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), Name = "Vegetariana" },
            new MenuCategory { Id = Guid.Parse("ffffffff-ffff-ffff-ffff-ffffffffffff"), Name = "Acaí e Sucos" }
        );
    }
}
