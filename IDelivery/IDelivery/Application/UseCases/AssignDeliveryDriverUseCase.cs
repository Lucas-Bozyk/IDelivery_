using IDelivery.Domain;
using IDelivery.Application.Ports;

namespace IDelivery.Application.UseCases;

public record AssignDeliveryDriverCommand(Guid DeliveryId, Guid DeliveryDriverId);

public class AssignDeliveryDriverUseCase(IDeliveryDispatchRepository repository)
{
    public async Task<Delivery> ExecuteAsync(AssignDeliveryDriverCommand command, CancellationToken ct = default)
    {
        var delivery = await repository.GetDeliveryAsync(command.DeliveryId, ct)
            ?? throw new InvalidOperationException("Delivery not found.");
        var driverExists = await repository.DriverExistsAsync(command.DeliveryDriverId, ct);
        if (!driverExists) throw new InvalidOperationException("Driver not found.");
        var activeDeliveries = await repository.CountActiveDeliveriesAsync(command.DeliveryDriverId, ct);
        if (activeDeliveries >= 3) throw new InvalidOperationException("Entregador ja possui 3 entregas simultaneas.");

        delivery.AssignDriver(command.DeliveryDriverId);
        await repository.SaveChangesAsync(ct);
        return delivery;
    }
}
