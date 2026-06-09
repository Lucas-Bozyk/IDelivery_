using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using IDelivery.Application.DTOs.Auth;
using IDelivery.Application.IServices;
using IDelivery.Application.Ports;
using IDelivery.Domain;
using IDelivery.Infrastructure.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace IDelivery.Application.Services;

public class AuthService(IAuthRepository authRepository, IAccountRegistrationService accountRegistration, IConfiguration configuration) : IAuthService
{
    public async Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken ct = default)
    {
        var name = request.Name?.Trim();
        if (string.IsNullOrWhiteSpace(name)) throw new InvalidOperationException("Name is required.");
        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        var exists = await authRepository.EmailExistsAsync(normalizedEmail, ct);
        if (exists) throw new InvalidOperationException("Email already registered.");

        var roleEnum = Enum.TryParse<UserRole>(request.Role, true, out var parsedRole) ? parsedRole : UserRole.Customer;
        if (roleEnum == UserRole.Admin) throw new InvalidOperationException("Admin users cannot be registered publicly.");

        var role = await authRepository.GetOrCreateRoleAsync(roleEnum, ct);

        var user = new User
        {
            Name = name,
            Email = normalizedEmail,
            PasswordHash = PasswordHasher.HashPassword(request.Password)
        };
        await authRepository.AddUserAsync(user, ct);
        await authRepository.SaveChangesAsync(ct);

        authRepository.AddUserRole(user.Id, role.Id);
        var rawRefreshToken = GenerateRefreshToken();
        var refresh = new RefreshToken { UserId = user.Id, Token = HashRefreshToken(rawRefreshToken), ExpiresAt = DateTime.UtcNow.AddDays(7) };
        authRepository.AddRefreshToken(refresh);
        await authRepository.SaveChangesAsync(ct);

        await accountRegistration.CreateDomainProfileAsync(user, roleEnum, request, ct);
        authRepository.UpdateUser(user);
        await authRepository.SaveChangesAsync(ct);

        var roles = new[] { role.Name.ToString() };
        return new AuthResponseDto(GenerateJwt(user, roles), rawRefreshToken);
    }

    public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken ct = default)
    {
        var user = await authRepository.GetUserByEmailAsync(request.Email.Trim().ToLowerInvariant(), ct)
            ?? throw new InvalidOperationException("Invalid credentials.");
        if (!PasswordHasher.VerifyPassword(request.Password, user.PasswordHash)) throw new InvalidOperationException("Invalid credentials.");

        var roles = await authRepository.GetRolesAsync(user.Id, ct);
        if (roles.Count == 0) roles.Add(UserRole.Customer.ToString());

        var primaryRole = roles
            .Select(x => Enum.TryParse<UserRole>(x, out var role) ? role : UserRole.Customer)
            .FirstOrDefault(x => x != UserRole.Admin);
        if (primaryRole != default && NeedsDomainProfile(user, primaryRole))
        {
            await accountRegistration.CreateDomainProfileAsync(user, primaryRole, new RegisterRequestDto
            {
                Name = user.Name,
                Email = user.Email,
                Password = request.Password,
                Role = primaryRole.ToString()
            }, ct);
            authRepository.UpdateUser(user);
        }

        var rawRefreshToken = GenerateRefreshToken();
        var refresh = new RefreshToken { UserId = user.Id, Token = HashRefreshToken(rawRefreshToken), ExpiresAt = DateTime.UtcNow.AddDays(7) };
        authRepository.AddRefreshToken(refresh);
        await authRepository.SaveChangesAsync(ct);
        return new AuthResponseDto(GenerateJwt(user, roles), rawRefreshToken);
    }

    public async Task<AuthResponseDto> RefreshAsync(RefreshTokenRequestDto request, CancellationToken ct = default)
    {
        var tokenHash = HashRefreshToken(request.RefreshToken);
        var refresh = await authRepository.GetRefreshTokenByHashAsync(tokenHash, ct)
            ?? throw new InvalidOperationException("Invalid refresh token.");
        if (!refresh.IsActive) throw new InvalidOperationException("Refresh token expired or revoked.");

        var user = await authRepository.GetUserByIdAsync(refresh.UserId, ct)
            ?? throw new InvalidOperationException("User not found.");
        var roles = await authRepository.GetRolesAsync(user.Id, ct);
        if (roles.Count == 0) roles.Add(UserRole.Customer.ToString());

        var newRawRefreshToken = GenerateRefreshToken();
        var newRefreshTokenHash = HashRefreshToken(newRawRefreshToken);
        refresh.RevokedAt = DateTime.UtcNow;
        refresh.ReplacedByToken = newRefreshTokenHash;
        authRepository.AddRefreshToken(new RefreshToken
        {
            UserId = user.Id,
            Token = newRefreshTokenHash,
            ExpiresAt = DateTime.UtcNow.AddDays(7)
        });
        await authRepository.SaveChangesAsync(ct);
        return new AuthResponseDto(GenerateJwt(user, roles), newRawRefreshToken);
    }

    public async Task LogoutAsync(LogoutRequestDto request, CancellationToken ct = default)
    {
        var tokenHash = HashRefreshToken(request.RefreshToken);
        var refresh = await authRepository.GetRefreshTokenByHashAsync(tokenHash, ct);
        if (refresh is null || refresh.RevokedAt is not null) return;
        refresh.RevokedAt = DateTime.UtcNow;
        await authRepository.SaveChangesAsync(ct);
    }

    private string GenerateJwt(User user, IEnumerable<string> roles)
    {
        var jwt = configuration.GetSection("Jwt");
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Email, user.Email)
        };
        if (user.CustomerId.HasValue) claims.Add(new("customer_id", user.CustomerId.Value.ToString()));
        if (user.DeliveryDriverId.HasValue) claims.Add(new("delivery_driver_id", user.DeliveryDriverId.Value.ToString()));
        if (user.RestaurantId.HasValue) claims.Add(new("restaurant_id", user.RestaurantId.Value.ToString()));
        claims.AddRange(roles.Select(r => new Claim(ClaimTypes.Role, r)));

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt["Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(jwt["Issuer"], jwt["Audience"], claims, expires: DateTime.UtcNow.AddHours(2), signingCredentials: creds);
        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static bool NeedsDomainProfile(User user, UserRole role) =>
        role switch
        {
            UserRole.Customer => !user.CustomerId.HasValue,
            UserRole.DeliveryDriver => !user.DeliveryDriverId.HasValue,
            UserRole.RestaurantOwner => !user.RestaurantId.HasValue,
            _ => false
        };

    private static string GenerateRefreshToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes);
    }

    private static string HashRefreshToken(string refreshToken)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(refreshToken));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }
}
