using AutoMapper;
using IDelivery.Application.DTOs.Customers;
using IDelivery.Application.DTOs.Orders;
using IDelivery.Application.DTOs.Products;
using IDelivery.Application.DTOs.Restaurants;
using IDelivery.Domain;

namespace IDelivery.Application.Mappings;

public class DomainToDtoProfile : Profile
{
    public DomainToDtoProfile()
    {
        CreateMap<Customer, CustomerMeDto>();
        CreateMap<CustomerAddress, AddressDto>();
        CreateMap<Restaurant, RestaurantDto>();
        CreateMap<Product, ProductDto>();
        CreateMap<Order, OrderDto>();
        CreateMap<Cart, IDelivery.Application.DTOs.Carts.CartDto>();
        CreateMap<CartItem, IDelivery.Application.DTOs.Carts.CartItemDto>();
        CreateMap<Review, IDelivery.Application.DTOs.Reviews.ReviewDto>();
        CreateMap<Payment, IDelivery.Application.DTOs.Payments.PaymentDto>();
        CreateMap<Delivery, IDelivery.Application.DTOs.Deliveries.DeliveryDto>();
    }
}
