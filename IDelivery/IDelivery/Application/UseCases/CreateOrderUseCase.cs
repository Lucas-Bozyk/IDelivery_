using IDelivery.Domain;
using IDelivery.Application.Ports;

namespace IDelivery.Application.UseCases;

public record CreateOrderCommand(Guid CustomerId, Guid? CouponId);

public class CreateOrderUseCase(ICreateOrderRepository repository)
{
    public async Task<Order> ExecuteAsync(CreateOrderCommand command, CancellationToken ct = default)
    {
        var address = await repository.GetPreferredAddressAsync(command.CustomerId, ct);
        if (address is null) throw new InvalidOperationException("Cliente nao pode criar pedido sem endereco valido.");

        var cart = await repository.GetActiveCartWithItemsAsync(command.CustomerId, ct)
            ?? throw new InvalidOperationException("Active cart not found.");
        if (cart.RestaurantId is null) throw new InvalidOperationException("Cart without restaurant.");

        var restaurant = await repository.GetRestaurantAsync(cart.RestaurantId.Value, ct)
            ?? throw new InvalidOperationException("Restaurant not found.");
        if (!restaurant.IsOpen) throw new InvalidOperationException("Restaurante fechado nao pode receber pedido.");

        var productIds = cart.Items.Select(i => i.ProductId).Distinct().ToList();
        var products = await repository.GetProductsAsync(productIds, ct);
        if (products.Any(p => p.RestaurantId != restaurant.Id))
            throw new InvalidOperationException("Pedido so pode conter produtos de um unico restaurante.");

        var subtotal = cart.Items.Sum(i =>
        {
            var p = products.First(x => x.Id == i.ProductId);
            return (p.PromotionalPrice ?? p.Price) * i.Quantity;
        });
        var deliveryFee = subtotal >= 60m ? 0m : 8m;
        var discount = 0m;

        if (command.CouponId.HasValue)
        {
            var coupon = await repository.GetCouponAsync(command.CouponId.Value, ct)
                ?? throw new InvalidOperationException("Coupon not found.");
            discount = coupon.Apply(subtotal);
        }

        var order = Order.Create(command.CustomerId, restaurant.Id, subtotal, deliveryFee, discount);

        await repository.AddOrderAsync(order, ct);
        var orderItems = cart.Items.Select(i =>
        {
            var p = products.First(x => x.Id == i.ProductId);
            var unitPrice = p.PromotionalPrice ?? p.Price;
            return new OrderItem
            {
                OrderId = order.Id,
                ProductId = p.Id,
                ProductName = p.Name,
                UnitPrice = unitPrice,
                Quantity = i.Quantity,
                TotalPrice = unitPrice * i.Quantity,
                Observation = i.Comment
            };
        }).ToList();
        await repository.AddOrderItemsAsync(orderItems, ct);
        await repository.AddDeliveryAsync(new Delivery
        {
            OrderId = order.Id,
            Status = DeliveryStatus.Pending,
            AddressSnapshot = $"{address.Street}, {address.Number} - {address.Neighborhood}, {address.City}/{address.State} - {address.ZipCode}",
            EstimatedDeliveryTime = DateTime.UtcNow.AddMinutes(45)
        }, ct);
        cart.IsActive = false;
        await repository.SaveChangesAsync(ct);
        return order;
    }
}
