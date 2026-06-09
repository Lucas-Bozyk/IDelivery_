using IDelivery.Domain;
using IDelivery.Application.Ports;

namespace IDelivery.Application.UseCases;

public record AddProductToCartCommand(Guid CustomerId, Guid ProductId, int Quantity, string? Comment = null);

public class AddProductToCartUseCase(IAddProductToCartRepository repository)
{
    public async Task<Cart> ExecuteAsync(AddProductToCartCommand command, CancellationToken ct = default)
    {
        if (command.Quantity <= 0) throw new InvalidOperationException("Quantidade deve ser maior que zero.");

        var product = await repository.GetProductAsync(command.ProductId, ct)
            ?? throw new InvalidOperationException("Product not found.");

        var cart = await repository.GetActiveCartWithItemsAsync(command.CustomerId, ct);
        if (cart is null)
        {
            cart = new Cart { CustomerId = command.CustomerId, IsActive = true };
            await repository.AddCartAsync(cart, ct);
        }

        if (cart.RestaurantId.HasValue && cart.RestaurantId.Value != product.RestaurantId)
        {
            var currentRestaurantName = await repository.GetRestaurantNameAsync(cart.RestaurantId.Value, ct);
            var productRestaurantName = await repository.GetRestaurantNameAsync(product.RestaurantId, ct);

            throw new InvalidOperationException(
                $"O carrinho ja possui itens de {currentRestaurantName ?? "outro restaurante"}. Limpe o carrinho antes de adicionar produtos de {productRestaurantName ?? "este restaurante"}.");
        }

        if (!product.IsAvailable) throw new InvalidOperationException("Produto indisponivel nao pode ser adicionado ao carrinho.");

        if (!cart.RestaurantId.HasValue) cart.RestaurantId = product.RestaurantId;

        var existingItem = await repository.GetCartItemAsync(cart.Id, product.Id, ct);
        if (existingItem is null)
        {
            await repository.AddCartItemAsync(new CartItem
            {
                CartId = cart.Id,
                ProductId = product.Id,
                Quantity = command.Quantity,
                Comment = command.Comment
            }, ct);
        }
        else
        {
            existingItem.Quantity += command.Quantity;
            if (!string.IsNullOrWhiteSpace(command.Comment)) existingItem.Comment = command.Comment;
        }

        await repository.SaveChangesAsync(ct);
        return cart;
    }
}
