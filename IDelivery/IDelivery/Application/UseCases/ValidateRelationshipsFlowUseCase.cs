using IDelivery.Application.Ports;

namespace IDelivery.Application.UseCases;

public class ValidateRelationshipsFlowUseCase(IRelationshipValidationPort validation)
{
    public Task<object> ExecuteAsync(CancellationToken ct = default) => validation.ExecuteAsync(ct);
}
