using System.Net;
using System.Net.Http.Json;
using IDelivery.Application.DTOs.Auth;
using IDelivery.Application.IServices;
using IDelivery.Tests.TestInfrastructure;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace IDelivery.Tests;

public class AuthRateLimitingE2ETests : IClassFixture<TestApiFactory>
{
    private readonly TestApiFactory _factory;

    public AuthRateLimitingE2ETests(TestApiFactory factory) => _factory = factory;

    [Fact]
    public async Task Login_Should_Return_TooManyRequests_When_RateLimit_Is_Exceeded()
    {
        using var factory = _factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureAppConfiguration((_, config) =>
            {
                config.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["RateLimiting:AuthLogin:PermitLimit"] = "1",
                    ["RateLimiting:AuthLogin:WindowMinutes"] = "10"
                });
            });
            builder.ConfigureTestServices(services =>
            {
                services.RemoveAll<IAuthService>();
                services.AddScoped<IAuthService, FakeAuthService>();
            });
        });

        var client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false
        });
        var request = new LoginRequestDto
        {
            Email = "rate.limit@test.local",
            Password = "StrongPass#123"
        };

        var first = await client.PostAsJsonAsync("/api/auth/login", request);
        var second = await client.PostAsJsonAsync("/api/auth/login", request);

        Assert.Equal(HttpStatusCode.OK, first.StatusCode);
        Assert.Equal(HttpStatusCode.TooManyRequests, second.StatusCode);
    }

    private sealed class FakeAuthService : IAuthService
    {
        public Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken ct = default) =>
            Task.FromResult(new AuthResponseDto("fake-access-token", "fake-refresh-token"));

        public Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken ct = default) =>
            Task.FromResult(new AuthResponseDto("fake-access-token", "fake-refresh-token"));

        public Task<AuthResponseDto> RefreshAsync(RefreshTokenRequestDto request, CancellationToken ct = default) =>
            Task.FromResult(new AuthResponseDto("fake-access-token", "fake-refresh-token"));

        public Task LogoutAsync(LogoutRequestDto request, CancellationToken ct = default) => Task.CompletedTask;
    }
}
