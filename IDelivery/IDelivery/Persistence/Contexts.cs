using IDelivery.Domain;
using IDelivery.Domain.Interfaces.IRepositories;
using IDelivery.Application.Ports;
using IDelivery.Persistence.Repositories;

namespace IDelivery.Persistence;

public static class PersistenceSetup
{
    public static IServiceCollection AddPersistence(this IServiceCollection services)
    {
        services.AddScoped<ICustomerRepository, CustomerRepository>();
        services.AddScoped<IRestaurantRepository, RestaurantRepository>();
        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<IOrderRepository, OrderRepository>();
        services.AddScoped<IUnitOfWork, DeliveryUnitOfWork>();
        services.AddScoped<IIdentityUserReadPort, IdentityUserPort>();
        services.AddScoped<IRestaurantOwnershipPort, IdentityUserPort>();
        services.AddScoped<ICartRepository, CartRepositoryPort>();
        services.AddScoped<ICatalogRepository, CatalogRepositoryPort>();
        services.AddScoped<IPaymentRepository, PaymentRepositoryPort>();
        services.AddScoped<ICouponRepository, CouponRepositoryPort>();
        services.AddScoped<IDeliveryRepository, DeliveryRepositoryPort>();
        services.AddScoped<IOrderQueryService, OrderQueryService>();
        services.AddScoped<IAuthRepository, AuthRepositoryPort>();
        services.AddScoped<IAccountProfileRepository, AccountProfileRepositoryPort>();
        services.AddScoped<ICustomerProfileRepository, CustomerProfileRepositoryPort>();
        services.AddScoped<IAddProductToCartRepository, CartWorkflowRepositoryPort>();
        services.AddScoped<ICreateOrderRepository, OrderWorkflowRepositoryPort>();
        services.AddScoped<ICreateRestaurantRepository, OrderWorkflowRepositoryPort>();
        services.AddScoped<IReviewRepository, OrderWorkflowRepositoryPort>();
        services.AddScoped<IDeliveryDispatchRepository, DeliveryDispatchRepositoryPort>();
        services.AddScoped<IOrderStatusRepository, OrderWorkflowRepositoryPort>();
        services.AddScoped<IPaymentProcessingRepository, OrderWorkflowRepositoryPort>();
        services.AddScoped<IRegisterCustomerRepository, OrderWorkflowRepositoryPort>();
        services.AddScoped<IRelationshipValidationPort, RelationshipValidationPort>();
        return services;
    }
}
