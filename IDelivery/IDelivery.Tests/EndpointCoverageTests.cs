using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Text;
using IDelivery.Application.DTOs.Auth;
using IDelivery.Application.DTOs.Carts;
using IDelivery.Application.DTOs.Common;
using IDelivery.Application.DTOs.Coupons;
using IDelivery.Application.DTOs.Customers;
using IDelivery.Application.DTOs.Deliveries;
using IDelivery.Application.DTOs.Orders;
using IDelivery.Application.DTOs.Payments;
using IDelivery.Application.DTOs.Products;
using IDelivery.Application.DTOs.Restaurants;
using IDelivery.Application.DTOs.Reviews;
using IDelivery.Application.IServices;
using IDelivery.Application.UseCases;
using IDelivery.Domain;
using IDelivery.Tests.TestInfrastructure;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.IdentityModel.Tokens;

namespace IDelivery.Tests;

public class EndpointCoverageTests : IClassFixture<TestApiFactory>
{
    private static readonly Guid UserId = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
    private static readonly Guid CustomerId = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb");
    private static readonly Guid RestaurantId = Guid.Parse("cccccccc-cccc-cccc-cccc-cccccccccccc");
    private static readonly Guid ProductId = Guid.Parse("dddddddd-dddd-dddd-dddd-dddddddddddd");
    private static readonly Guid CategoryId = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee");
    private static readonly Guid OrderId = Guid.Parse("11111111-2222-3333-4444-555555555555");
    private static readonly Guid DeliveryId = Guid.Parse("66666666-7777-8888-9999-000000000000");
    private static readonly Guid DriverId = Guid.Parse("12345678-1234-1234-1234-123456789012");
    private static readonly Guid AddressId = Guid.Parse("98765432-1234-1234-1234-123456789012");
    private static readonly Guid PaymentId = Guid.Parse("24682468-1234-1234-1234-123456789012");

    private readonly WebApplicationFactory<Program> _factory;

    public EndpointCoverageTests(TestApiFactory factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureTestServices(services =>
            {
                services.RemoveAll<IAuthService>();
                services.RemoveAll<ICatalogService>();
                services.RemoveAll<ICartService>();
                services.RemoveAll<ICustomerService>();
                services.RemoveAll<IRestaurantService>();
                services.RemoveAll<IProductService>();
                services.RemoveAll<IOrderService>();
                services.RemoveAll<IPaymentService>();
                services.RemoveAll<IDeliveryService>();
                services.RemoveAll<ICouponService>();
                services.RemoveAll<IReviewService>();
                services.RemoveAll<IDevValidationService>();

                services.AddSingleton<IAuthService, FakeAuthService>();
                services.AddSingleton<ICatalogService, FakeCatalogService>();
                services.AddSingleton<ICartService, FakeCartService>();
                services.AddSingleton<ICustomerService, FakeCustomerService>();
                services.AddSingleton<IRestaurantService, FakeRestaurantService>();
                services.AddSingleton<IProductService, FakeProductService>();
                services.AddSingleton<IOrderService, FakeOrderService>();
                services.AddSingleton<IPaymentService, FakePaymentService>();
                services.AddSingleton<IDeliveryService, FakeDeliveryService>();
                services.AddSingleton<ICouponService, FakeCouponService>();
                services.AddSingleton<IReviewService, FakeReviewService>();
                services.AddSingleton<IDevValidationService, FakeDevValidationService>();
            });
        });
    }

    [Fact]
    public async Task All_Api_Routes_Should_Be_Covered_By_E2E_Requests()
    {
        var anonymous = _factory.CreateClient();
        var customer = CreateClient(UserRole.Customer);
        var admin = CreateClient(UserRole.Admin);
        var restaurantOwner = CreateClient(UserRole.RestaurantOwner);
        var driver = CreateClient(UserRole.DeliveryDriver);

        await AssertStatusAsync(await anonymous.PostAsJsonAsync("/api/auth/register", new RegisterRequestDto { Name = "User", Email = "user@test.local", Password = "StrongPass#123", Role = "Customer" }), HttpStatusCode.OK);
        var loginResponse = await anonymous.PostAsJsonAsync("/api/auth/login", new LoginRequestDto { Email = "user@test.local", Password = "StrongPass#123" });
        await AssertStatusAsync(loginResponse, HttpStatusCode.OK);
        anonymous.DefaultRequestHeaders.Add("Cookie", ExtractRefreshCookie(loginResponse));
        await AssertStatusAsync(await anonymous.PostAsync("/api/auth/refresh-token", null), HttpStatusCode.OK);
        await AssertStatusAsync(await anonymous.PostAsync("/api/auth/logout", null), HttpStatusCode.NoContent);

        await AssertStatusAsync(await anonymous.GetAsync("/api/menu-categories"), HttpStatusCode.OK);
        await AssertStatusAsync(await anonymous.GetAsync("/api/restaurant-categories"), HttpStatusCode.OK);

        await AssertStatusAsync(await customer.GetAsync("/api/customers/me"), HttpStatusCode.OK);
        await AssertStatusAsync(await customer.PutAsJsonAsync("/api/customers/me", new UpdateCustomerMeRequestDto { FullName = "Cliente Teste", Phone = "11999999999" }), HttpStatusCode.NoContent);
        await AssertStatusAsync(await customer.PostAsJsonAsync("/api/customers/addresses", AddressRequest()), HttpStatusCode.OK);
        await AssertStatusAsync(await customer.GetAsync("/api/customers/addresses"), HttpStatusCode.OK);
        await AssertStatusAsync(await customer.PutAsJsonAsync($"/api/customers/addresses/{AddressId}", AddressRequest()), HttpStatusCode.NoContent);
        await AssertStatusAsync(await customer.DeleteAsync($"/api/customers/addresses/{AddressId}"), HttpStatusCode.NoContent);

        await AssertStatusAsync(await customer.GetAsync("/api/cart"), HttpStatusCode.OK);
        await AssertStatusAsync(await customer.PostAsJsonAsync("/api/cart/items", new AddProductToCartCommand(Guid.Empty, ProductId, 1, "sem cebola")), HttpStatusCode.OK);
        await AssertStatusAsync(await customer.PutAsJsonAsync($"/api/cart/items/{ProductId}", 2), HttpStatusCode.NoContent);
        await AssertStatusAsync(await customer.DeleteAsync($"/api/cart/items/{ProductId}"), HttpStatusCode.NoContent);
        await AssertStatusAsync(await customer.DeleteAsync("/api/cart"), HttpStatusCode.NoContent);

        await AssertStatusAsync(await anonymous.GetAsync("/api/restaurants"), HttpStatusCode.OK);
        await AssertStatusAsync(await anonymous.GetAsync($"/api/restaurants/{RestaurantId}"), HttpStatusCode.OK);
        await AssertStatusAsync(await restaurantOwner.PostAsJsonAsync("/api/restaurants", new CreateRestaurantCommand("Restaurante", "Descricao", "12345678000199", "11999999999", "rest@test.local", CategoryId)), HttpStatusCode.OK);
        await AssertStatusAsync(await restaurantOwner.PutAsJsonAsync($"/api/restaurants/{RestaurantId}", RestaurantRequest()), HttpStatusCode.NoContent);
        await AssertStatusAsync(await restaurantOwner.PatchAsJsonAsync($"/api/restaurants/{RestaurantId}/open-status", true), HttpStatusCode.NoContent);
        await AssertStatusAsync(await anonymous.GetAsync($"/api/restaurants/{RestaurantId}/products"), HttpStatusCode.OK);
        await AssertStatusAsync(await restaurantOwner.PostAsJsonAsync($"/api/restaurants/{RestaurantId}/products", ProductRequest()), HttpStatusCode.OK);
        await AssertStatusAsync(await anonymous.GetAsync($"/api/restaurants/{RestaurantId}/reviews"), HttpStatusCode.OK);

        await AssertStatusAsync(await anonymous.GetAsync($"/api/products/{ProductId}"), HttpStatusCode.OK);
        await AssertStatusAsync(await restaurantOwner.PutAsJsonAsync($"/api/products/{ProductId}", UpdateProductRequest()), HttpStatusCode.NoContent);
        await AssertStatusAsync(await restaurantOwner.DeleteAsync($"/api/products/{ProductId}"), HttpStatusCode.NoContent);

        await AssertStatusAsync(await customer.PostAsJsonAsync("/api/orders", (Guid?)null), HttpStatusCode.OK);
        await AssertStatusAsync(await customer.GetAsync("/api/orders"), HttpStatusCode.OK);
        await AssertStatusAsync(await restaurantOwner.GetAsync($"/api/orders/restaurant/{RestaurantId}"), HttpStatusCode.OK);
        await AssertStatusAsync(await restaurantOwner.GetAsync($"/api/orders/restaurant/{RestaurantId}/{OrderId}"), HttpStatusCode.OK);
        await AssertStatusAsync(await customer.GetAsync($"/api/orders/{OrderId}"), HttpStatusCode.OK);
        await AssertStatusAsync(await restaurantOwner.PatchAsJsonAsync($"/api/orders/{OrderId}/status", OrderStatus.Preparing), HttpStatusCode.NoContent);
        await AssertStatusAsync(await customer.PostAsync($"/api/orders/{OrderId}/cancel", null), HttpStatusCode.NoContent);

        await AssertStatusAsync(await customer.PostAsJsonAsync("/api/payments", new ProcessPaymentRequestDto(OrderId, PaymentMethod.Pix)), HttpStatusCode.OK);
        await AssertStatusAsync(await anonymous.PostAsJsonAsync("/api/payments/webhook", PaymentId), HttpStatusCode.OK);

        await AssertStatusAsync(await admin.GetAsync("/api/deliveries"), HttpStatusCode.OK);
        await AssertStatusAsync(await driver.GetAsync("/api/deliveries/me"), HttpStatusCode.OK);
        await AssertStatusAsync(await admin.PostAsync("/api/deliveries/dispatch", null), HttpStatusCode.OK);
        await AssertStatusAsync(await driver.PatchAsJsonAsync($"/api/deliveries/{DeliveryId}/status", DeliveryStatus.PickedUp), HttpStatusCode.NoContent);
        await AssertStatusAsync(await admin.PatchAsJsonAsync($"/api/deliveries/{DeliveryId}/assign-driver", DriverId), HttpStatusCode.OK);

        await AssertStatusAsync(await admin.PostAsJsonAsync("/api/coupons", CouponRequest()), HttpStatusCode.OK);
        await AssertStatusAsync(await anonymous.GetAsync("/api/coupons/DESC10/validate?orderTotal=100"), HttpStatusCode.OK);

        await AssertStatusAsync(await customer.PostAsJsonAsync("/api/reviews", new CreateReviewCommand(Guid.Empty, OrderId, 5, "ok")), HttpStatusCode.OK);
        await AssertStatusAsync(await admin.PostAsync("/api/dev/validate-relationships-flow", null), HttpStatusCode.OK);
    }

    private HttpClient CreateClient(UserRole role)
    {
        var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", CreateJwt(role));
        return client;
    }

    private static string CreateJwt(UserRole role)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, UserId.ToString()),
            new Claim(ClaimTypes.Email, $"{role.ToString().ToLowerInvariant()}@test.local"),
            new Claim(ClaimTypes.Role, role.ToString())
        };
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("THIS_IS_A_32_PLUS_CHAR_TEST_ONLY_SECRET_KEY_123"));
        var token = new JwtSecurityToken(
            issuer: "IDelivery.Tests",
            audience: "IDelivery.Tests.Client",
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256));
        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static async Task AssertStatusAsync(HttpResponseMessage response, HttpStatusCode expected)
    {
        var body = await response.Content.ReadAsStringAsync();
        Assert.True(response.StatusCode == expected, $"Expected {(int)expected} but got {(int)response.StatusCode}. Body: {body}");
    }

    private static string ExtractRefreshCookie(HttpResponseMessage response)
    {
        var setCookie = response.Headers.GetValues("Set-Cookie").First(x => x.StartsWith("idelivery_refresh_token=", StringComparison.OrdinalIgnoreCase));
        return setCookie.Split(';')[0];
    }

    private static UpsertCustomerAddressRequestDto AddressRequest() => new()
    {
        Street = "Rua A",
        Number = "10",
        Neighborhood = "Centro",
        City = "Sao Paulo",
        State = "SP",
        ZipCode = "01001000",
        IsDefault = true
    };

    private static UpdateRestaurantRequestDto RestaurantRequest() => new()
    {
        Name = "Restaurante",
        Description = "Descricao",
        Cnpj = "12345678000199",
        Phone = "11999999999",
        Email = "rest@test.local",
        CategoryId = CategoryId
    };

    private static CreateProductRequestDto ProductRequest() => new()
    {
        MenuCategoryId = CategoryId,
        Name = "Produto",
        Description = "Descricao",
        Price = 10,
        IsAvailable = true
    };

    private static UpdateProductRequestDto UpdateProductRequest() => new()
    {
        MenuCategoryId = CategoryId,
        Name = "Produto atualizado",
        Description = "Descricao atualizada",
        Price = 12,
        IsAvailable = true
    };

    private static CreateCouponRequestDto CouponRequest() => new()
    {
        Code = "DESC10",
        DiscountType = DiscountType.Percentage,
        Value = 10,
        MinValue = 1,
        ExpirationDate = DateTime.UtcNow.AddDays(1),
        UsageLimit = 10
    };

    private sealed class FakeAuthService : IAuthService
    {
        public Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken ct = default) => AuthAsync();
        public Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken ct = default) => AuthAsync();
        public Task<AuthResponseDto> RefreshAsync(RefreshTokenRequestDto request, CancellationToken ct = default) => AuthAsync();
        public Task LogoutAsync(LogoutRequestDto request, CancellationToken ct = default) => Task.CompletedTask;
        private static Task<AuthResponseDto> AuthAsync() => Task.FromResult(new AuthResponseDto(CreateJwt(UserRole.Customer), "fake-refresh-token"));
    }

    private sealed class FakeCatalogService : ICatalogService
    {
        public Task<List<CategoryDto>> GetMenuCategoriesAsync(CancellationToken ct = default) => Task.FromResult(new List<CategoryDto> { new(CategoryId, "Lanches") });
        public Task<List<CategoryDto>> GetRestaurantCategoriesAsync(CancellationToken ct = default) => Task.FromResult(new List<CategoryDto> { new(CategoryId, "Hamburgueria") });
    }

    private sealed class FakeCartService : ICartService
    {
        public Task<CartDto?> GetActiveCartAsync(Guid userId, CancellationToken ct = default) => Task.FromResult<CartDto?>(new CartDto(Guid.NewGuid(), CustomerId, []));
        public Task<CartDto> AddItemAsync(Guid userId, AddProductToCartCommand command, CancellationToken ct = default) => Task.FromResult(new CartDto(Guid.NewGuid(), CustomerId, [new CartItemDto(ProductId, command.ProductId, command.Quantity, command.Comment)]));
        public Task<bool> UpdateItemAsync(Guid userId, Guid itemId, int quantity, CancellationToken ct = default) => Task.FromResult(true);
        public Task<bool> RemoveItemAsync(Guid userId, Guid itemId, CancellationToken ct = default) => Task.FromResult(true);
        public Task ClearAsync(Guid userId, CancellationToken ct = default) => Task.CompletedTask;
    }

    private sealed class FakeCustomerService : ICustomerService
    {
        public Task<CustomerMeDto?> GetMeAsync(Guid userId, CancellationToken ct = default) => Task.FromResult<CustomerMeDto?>(new CustomerMeDto(CustomerId, "Cliente", "11999999999"));
        public Task<CustomerMeDto?> UpdateMeAsync(Guid userId, UpdateCustomerMeRequestDto request, CancellationToken ct = default) => Task.FromResult<CustomerMeDto?>(new CustomerMeDto(CustomerId, request.FullName, request.Phone));
        public Task<AddressDto> AddAddressAsync(Guid userId, UpsertCustomerAddressRequestDto request, CancellationToken ct = default) => Task.FromResult(new AddressDto(AddressId, request.Street, request.Number, request.Complement, request.Neighborhood, request.City, request.State, request.ZipCode, request.IsDefault));
        public Task<List<AddressDto>> GetAddressesAsync(Guid userId, CancellationToken ct = default) => Task.FromResult(new List<AddressDto> { new(AddressId, "Rua A", "10", null, "Centro", "Sao Paulo", "SP", "01001000", true) });
        public Task<bool> UpdateAddressAsync(Guid userId, Guid addressId, UpsertCustomerAddressRequestDto request, CancellationToken ct = default) => Task.FromResult(true);
        public Task<bool> DeleteAddressAsync(Guid userId, Guid addressId, CancellationToken ct = default) => Task.FromResult(true);
        public Task<Guid> GetCustomerIdAsync(Guid userId, CancellationToken ct = default) => Task.FromResult(CustomerId);
    }

    private sealed class FakeRestaurantService : IRestaurantService
    {
        public Task<List<RestaurantDto>> GetAllAsync(CancellationToken ct = default) => Task.FromResult(new List<RestaurantDto> { RestaurantDto() });
        public Task<RestaurantDto?> GetAsync(Guid id, CancellationToken ct = default) => Task.FromResult<RestaurantDto?>(RestaurantDto());
        public Task<Restaurant> CreateAsync(Guid userId, bool isAdmin, CreateRestaurantCommand command, CancellationToken ct = default) => Task.FromResult(new Restaurant { Id = RestaurantId, Name = command.Name, Description = command.Description, Cnpj = command.Cnpj, Phone = command.Phone, Email = command.Email, CategoryId = command.CategoryId, IsOpen = true });
        public Task<bool> UpdateAsync(Guid userId, bool isAdmin, Guid id, UpdateRestaurantRequestDto request, CancellationToken ct = default) => Task.FromResult(true);
        public Task<bool> UpdateOpenStatusAsync(Guid userId, bool isAdmin, Guid id, bool isOpen, CancellationToken ct = default) => Task.FromResult(true);
        public Task<List<ProductDto>> GetProductsAsync(Guid restaurantId, CancellationToken ct = default) => Task.FromResult(new List<ProductDto> { ProductDto() });
        public Task<ProductDto> CreateProductAsync(Guid userId, bool isAdmin, Guid restaurantId, CreateProductRequestDto request, CancellationToken ct = default) => Task.FromResult(ProductDto());
        public Task<List<ReviewDto>> GetReviewsAsync(Guid restaurantId, CancellationToken ct = default) => Task.FromResult(new List<ReviewDto> { ReviewDto() });
        private static RestaurantDto RestaurantDto() => new(RestaurantId, "Restaurante", "Descricao", "12345678000199", "11999999999", "rest@test.local", null, true, CategoryId, DateTime.UtcNow, DateTime.UtcNow);
    }

    private sealed class FakeProductService : IProductService
    {
        public Task<List<ProductDto>> GetByRestaurantAsync(Guid restaurantId, CancellationToken ct = default) => Task.FromResult(new List<ProductDto> { ProductDto() });
        public Task<ProductDto?> GetByIdAsync(Guid id, CancellationToken ct = default) => Task.FromResult<ProductDto?>(ProductDto());
        public Task<bool> UpdateAsync(Guid userId, bool isAdmin, Guid id, UpdateProductRequestDto request, CancellationToken ct = default) => Task.FromResult(true);
        public Task<bool> DeleteAsync(Guid userId, bool isAdmin, Guid id, CancellationToken ct = default) => Task.FromResult(true);
    }

    private sealed class FakeOrderService : IOrderService
    {
        public Task<List<OrderDto>> GetByCustomerAsync(Guid customerId, CancellationToken ct = default) => Task.FromResult(new List<OrderDto> { new(OrderId, OrderStatus.Created, 10) });
        public Task<OrderDto?> GetByIdAsync(Guid id, CancellationToken ct = default) => Task.FromResult<OrderDto?>(new OrderDto(id, OrderStatus.Created, 10));
        public Task<Order> CreateAsync(Guid userId, Guid? couponId, CancellationToken ct = default) => Task.FromResult(Order.Create(CustomerId, RestaurantId, 10, 8, 0));
        public Task<List<CustomerOrderSummaryDto>> GetByCustomerUserAsync(Guid userId, CancellationToken ct = default) => Task.FromResult(new List<CustomerOrderSummaryDto> { CustomerOrderSummary() });
        public Task<OrderDto?> GetCustomerOrderAsync(Guid userId, Guid id, CancellationToken ct = default) => Task.FromResult<OrderDto?>(new OrderDto(id, OrderStatus.Created, 18));
        public Task<List<RestaurantOrderSummaryDto>> GetByRestaurantAsync(Guid userId, bool isAdmin, Guid restaurantId, CancellationToken ct = default) => Task.FromResult(new List<RestaurantOrderSummaryDto> { RestaurantOrderSummary() });
        public Task<RestaurantOrderDetailsDto?> GetRestaurantOrderAsync(Guid userId, bool isAdmin, Guid restaurantId, Guid orderId, CancellationToken ct = default) => Task.FromResult<RestaurantOrderDetailsDto?>(new RestaurantOrderDetailsDto(RestaurantOrderSummary(), [new RestaurantOrderItemDto(Guid.NewGuid(), ProductId, "Produto", 10, 1, 10, "obs")]));
        public Task UpdateStatusAsync(Guid userId, bool isAdmin, Guid orderId, OrderStatus status, CancellationToken ct = default) => Task.CompletedTask;
        public Task<bool> CancelAsync(Guid userId, Guid orderId, CancellationToken ct = default) => Task.FromResult(true);
    }

    private sealed class FakePaymentService : IPaymentService
    {
        public Task<PaymentDto> CreateAsync(Guid userId, ProcessPaymentRequestDto request, CancellationToken ct = default) => Task.FromResult(new PaymentDto(PaymentId, PaymentStatus.Approved, 18, "fake"));
        public Task ProcessWebhookAsync(Guid paymentId, string? providedSignature, CancellationToken ct = default) => Task.CompletedTask;
    }

    private sealed class FakeDeliveryService : IDeliveryService
    {
        public Task<List<DeliveryDto>> ListAsync(CancellationToken ct = default) => Task.FromResult(new List<DeliveryDto> { new(DeliveryId, DeliveryStatus.Assigned, DriverId) });
        public Task<List<DriverDeliveryDto>> GetMineAsync(Guid userId, CancellationToken ct = default) => Task.FromResult(new List<DriverDeliveryDto> { new(DeliveryId, OrderId, DriverId, DeliveryStatus.Assigned, "Rua A, 10", DateTime.UtcNow.AddMinutes(30), null, DateTime.UtcNow, RestaurantId, "Restaurante") });
        public Task<DispatchDeliveriesResult> DispatchAsync(CancellationToken ct = default) => Task.FromResult(new DispatchDeliveriesResult(1));
        public Task UpdateStatusAsync(Guid userId, bool isDeliveryDriver, Guid deliveryId, DeliveryStatus status, CancellationToken ct = default) => Task.CompletedTask;
        public Task<DeliveryDto> AssignAsync(Guid deliveryId, Guid driverId, CancellationToken ct = default) => Task.FromResult(new DeliveryDto(deliveryId, DeliveryStatus.Assigned, driverId));
    }

    private sealed class FakeCouponService : ICouponService
    {
        public Task<Coupon> CreateAsync(CreateCouponRequestDto request, CancellationToken ct = default) => Task.FromResult(new Coupon { Id = Guid.NewGuid(), Code = request.Code, DiscountType = request.DiscountType, Value = request.Value, MinValue = request.MinValue, ExpirationDate = request.ExpirationDate, UsageLimit = request.UsageLimit });
        public Task<CouponValidationDto> ValidateAsync(string code, decimal orderTotal, CancellationToken ct = default) => Task.FromResult(new CouponValidationDto(code, true));
    }

    private sealed class FakeReviewService : IReviewService
    {
        public Task<ReviewDto> CreateAsync(Guid userId, CreateReviewCommand command, CancellationToken ct = default) => Task.FromResult(ReviewDto());
    }

    private sealed class FakeDevValidationService : IDevValidationService
    {
        public Task<object> ValidateRelationshipsFlowAsync(CancellationToken ct = default) => Task.FromResult<object>(new { ok = true });
    }

    private static ProductDto ProductDto() => new(ProductId, RestaurantId, CategoryId, "Produto", "Descricao", 10, null, true, null);
    private static ReviewDto ReviewDto() => new(Guid.NewGuid(), CustomerId, RestaurantId, OrderId, 5, "ok", DateTime.UtcNow);
    private static CustomerOrderSummaryDto CustomerOrderSummary() => new(OrderId, CustomerId, RestaurantId, "Restaurante", OrderStatus.Created, 10, 8, 0, 18, DateTime.UtcNow, null, null, null);
    private static RestaurantOrderSummaryDto RestaurantOrderSummary() => new(OrderId, OrderStatus.Created, 18, 10, 8, 0, DateTime.UtcNow);
}

