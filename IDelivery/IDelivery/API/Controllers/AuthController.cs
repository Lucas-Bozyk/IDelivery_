using System.Security.Claims;
using IDelivery.Application.DTOs.Auth;
using IDelivery.Application.DTOs.Customers;
using IDelivery.Application.DTOs.Coupons;
using IDelivery.Application.DTOs.Products;
using IDelivery.Application.DTOs.Restaurants;
using IDelivery.Application.IServices;
using IDelivery.Application.UseCases;
using IDelivery.Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace IDelivery.Api;
[ApiController, Route("api/auth")]
public class AuthController(IAuthService service, IWebHostEnvironment environment) : ControllerBase
{
    private const string RefreshTokenCookieName = "idelivery_refresh_token";

    [HttpPost("register"), AllowAnonymous, EnableRateLimiting("AuthRegister")]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto request)
    {
        var auth = await service.RegisterAsync(request);
        SetRefreshTokenCookie(auth.RefreshToken);
        return Ok(new { token = auth.Token });
    }

    [HttpPost("login"), AllowAnonymous, EnableRateLimiting("AuthLogin")]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
    {
        var auth = await service.LoginAsync(request);
        SetRefreshTokenCookie(auth.RefreshToken);
        return Ok(new { token = auth.Token });
    }

    [HttpPost("refresh-token"), AllowAnonymous, EnableRateLimiting("AuthRefresh")]
    public async Task<IActionResult> Refresh()
    {
        var refreshToken = Request.Cookies[RefreshTokenCookieName];
        if (string.IsNullOrWhiteSpace(refreshToken)) return Unauthorized(new { error = "Missing refresh token." });

        var auth = await service.RefreshAsync(new RefreshTokenRequestDto { RefreshToken = refreshToken });
        SetRefreshTokenCookie(auth.RefreshToken);
        return Ok(new { token = auth.Token });
    }

    [HttpPost("logout"), AllowAnonymous]
    public async Task<IActionResult> Logout()
    {
        var refreshToken = Request.Cookies[RefreshTokenCookieName];
        if (!string.IsNullOrWhiteSpace(refreshToken))
            await service.LogoutAsync(new LogoutRequestDto { RefreshToken = refreshToken });
        ClearRefreshTokenCookie();
        return NoContent();
    }

    private void SetRefreshTokenCookie(string refreshToken)
    {
        Response.Cookies.Append(RefreshTokenCookieName, refreshToken, BuildRefreshTokenCookieOptions(DateTimeOffset.UtcNow.AddDays(7)));
    }

    private void ClearRefreshTokenCookie()
    {
        Response.Cookies.Delete(RefreshTokenCookieName, BuildRefreshTokenCookieOptions(DateTimeOffset.UtcNow.AddDays(-1)));
    }

    private CookieOptions BuildRefreshTokenCookieOptions(DateTimeOffset expires) =>
        new()
        {
            HttpOnly = true,
            Secure = !environment.IsDevelopment(),
            SameSite = environment.IsDevelopment() ? SameSiteMode.Lax : SameSiteMode.None,
            Expires = expires,
            Path = "/api/auth"
        };
}

