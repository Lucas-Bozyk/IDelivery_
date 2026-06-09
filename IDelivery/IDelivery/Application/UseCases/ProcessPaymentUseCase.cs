using IDelivery.Domain;
using IDelivery.Infrastructure;
using IDelivery.Application.Ports;

namespace IDelivery.Application.UseCases;

public record ProcessPaymentCommand(Guid CustomerId, Guid OrderId, PaymentMethod Method);

public class ProcessPaymentUseCase(IPaymentProcessingRepository repository, IPaymentGateway paymentGateway)
{
    public async Task<Payment> ExecuteAsync(ProcessPaymentCommand command, CancellationToken ct = default)
    {
        var order = await repository.GetOrderAsync(command.OrderId, ct)
            ?? throw new InvalidOperationException("Order not found.");
        if (order.CustomerId != command.CustomerId)
            throw new UnauthorizedAccessException("Order does not belong to this customer.");

        var approved = await paymentGateway.ProcessAsync(order.Total, command.Method.ToString());
        var payment = Payment.Create(order.Id, command.Method, order.Total, approved);

        await repository.AddPaymentAsync(payment, ct);
        if (approved) order.ConfirmPayment();

        await repository.SaveChangesAsync(ct);
        return payment;
    }
}
