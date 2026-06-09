using IDelivery.Domain;
using IDelivery.Application.Ports;

namespace IDelivery.Application.UseCases;

public record UpdateOrderStatusCommand(Guid OrderId, OrderStatus Status);

public class UpdateOrderStatusUseCase(IOrderStatusRepository repository)
{
    public async Task ExecuteAsync(UpdateOrderStatusCommand command, CancellationToken ct = default)
    {
        var order = await repository.GetOrderAsync(command.OrderId, ct)
            ?? throw new InvalidOperationException("Order not found.");
        order.UpdateStatus(command.Status);
        await repository.SaveChangesAsync(ct);
    }
}
