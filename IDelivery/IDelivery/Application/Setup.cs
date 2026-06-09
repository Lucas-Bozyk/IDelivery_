namespace IDelivery.Application;

public static class ApplicationSetup
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddAutoMapper(typeof(IDelivery.Application.Mappings.DomainToDtoProfile).Assembly);
        services.AddScoped<IDelivery.Application.UseCases.RegisterCustomerUseCase>();
        services.AddScoped<IDelivery.Application.UseCases.CreateRestaurantUseCase>();
        services.AddScoped<IDelivery.Application.UseCases.AddProductToCartUseCase>();
        services.AddScoped<IDelivery.Application.UseCases.CreateOrderUseCase>();
        services.AddScoped<IDelivery.Application.UseCases.ProcessPaymentUseCase>();
        services.AddScoped<IDelivery.Application.UseCases.UpdateOrderStatusUseCase>();
        services.AddScoped<IDelivery.Application.UseCases.AssignDeliveryDriverUseCase>();
        services.AddScoped<IDelivery.Application.UseCases.DispatchDeliveriesUseCase>();
        services.AddScoped<IDelivery.Application.UseCases.CreateReviewUseCase>();
        services.AddScoped<IDelivery.Application.UseCases.ValidateRelationshipsFlowUseCase>();
        services.AddScoped<IDelivery.Application.IServices.IAuthService, IDelivery.Application.Services.AuthService>();
        services.AddScoped<IDelivery.Application.IServices.IAccountRegistrationService, IDelivery.Application.Services.AccountRegistrationService>();
        services.AddScoped<IDelivery.Application.IServices.ICustomerService, IDelivery.Application.Services.CustomerService>();
        services.AddScoped<IDelivery.Application.IServices.IRestaurantService, IDelivery.Application.Services.RestaurantService>();
        services.AddScoped<IDelivery.Application.IServices.IProductService, IDelivery.Application.Services.ProductService>();
        services.AddScoped<IDelivery.Application.IServices.IOrderService, IDelivery.Application.Services.OrderService>();
        services.AddScoped<IDelivery.Application.IServices.ICatalogService, IDelivery.Application.Services.CatalogService>();
        services.AddScoped<IDelivery.Application.IServices.ICartService, IDelivery.Application.Services.CartService>();
        services.AddScoped<IDelivery.Application.IServices.IPaymentService, IDelivery.Application.Services.PaymentService>();
        services.AddScoped<IDelivery.Application.IServices.IDeliveryService, IDelivery.Application.Services.DeliveryService>();
        services.AddScoped<IDelivery.Application.IServices.ICouponService, IDelivery.Application.Services.CouponService>();
        services.AddScoped<IDelivery.Application.IServices.IReviewService, IDelivery.Application.Services.ReviewService>();
        services.AddScoped<IDelivery.Application.IServices.IDevValidationService, IDelivery.Application.Services.DevValidationService>();
        return services;
    }
}
