using IDelivery.Domain;
using IDelivery.Application.Ports;

namespace IDelivery.Application.UseCases;

public record DispatchDeliveriesResult(int AssignedCount);

public class DispatchDeliveriesUseCase(IDeliveryDispatchRepository repository)
{
    private const int MaxActiveDeliveriesPerDriver = 3;

    public async Task<DispatchDeliveriesResult> ExecuteAsync(CancellationToken ct = default)
    {
        var pendingDeliveries = await repository.GetPendingDeliveriesAsync(ct);
        if (pendingDeliveries.Count == 0) return new DispatchDeliveriesResult(0);

        var drivers = await repository.GetDriversAsync(ct);
        if (drivers.Count == 0) return new DispatchDeliveriesResult(0);

        var driverLoads = await repository.GetActiveDeliveryCountsAsync(ct);

        var assignedCount = 0;
        foreach (var delivery in pendingDeliveries)
        {
            var driver = drivers
                .Select(x => new { Driver = x, ActiveCount = driverLoads.GetValueOrDefault(x.Id, 0) })
                .Where(x => x.ActiveCount < MaxActiveDeliveriesPerDriver)
                .OrderBy(x => x.ActiveCount)
                .ThenBy(x => x.Driver.Name)
                .FirstOrDefault();

            if (driver is null) break;

            delivery.AssignDriver(driver.Driver.Id);
            driverLoads[driver.Driver.Id] = driver.ActiveCount + 1;
            assignedCount++;
        }

        await repository.SaveChangesAsync(ct);
        return new DispatchDeliveriesResult(assignedCount);
    }
}
