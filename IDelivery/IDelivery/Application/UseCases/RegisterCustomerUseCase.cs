using IDelivery.Domain;
using IDelivery.Infrastructure;
using IDelivery.Application.Ports;

namespace IDelivery.Application.UseCases;

public record RegisterCustomerCommand(Guid UserId, string FullName, string Phone, string? Cpf);

public class RegisterCustomerUseCase(IRegisterCustomerRepository repository, IEmailService emailService)
{
    public async Task<Customer> ExecuteAsync(RegisterCustomerCommand command, CancellationToken ct = default)
    {
        var customer = new Customer
        {
            UserId = command.UserId,
            FullName = command.FullName,
            Phone = command.Phone,
            Cpf = command.Cpf
        };
        await repository.AddCustomerAsync(customer, ct);
        await repository.SaveChangesAsync(ct);
        await emailService.SendAsync("customer@local", "Welcome", "Customer registered");
        return customer;
    }
}
