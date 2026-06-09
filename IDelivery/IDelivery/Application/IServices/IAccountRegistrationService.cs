using IDelivery.Application.DTOs.Auth;
using IDelivery.Domain;

namespace IDelivery.Application.IServices;

public interface IAccountRegistrationService
{
    Task CreateDomainProfileAsync(User user, UserRole role, RegisterRequestDto request, CancellationToken ct = default);
}
