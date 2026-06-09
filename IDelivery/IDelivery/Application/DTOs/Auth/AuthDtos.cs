namespace IDelivery.Application.DTOs.Auth;

using System.ComponentModel.DataAnnotations;

public record AuthResponseDto(string Token, string RefreshToken);

public class RegisterRequestDto
{
    [Required, StringLength(120, MinimumLength = 2)]
    public string Name { get; set; } = "";

    [Required, EmailAddress, StringLength(120)]
    public string Email { get; set; } = "";

    [Required, StringLength(120, MinimumLength = 8)]
    public string Password { get; set; } = "";

    [Required, RegularExpression("Customer|RestaurantOwner|DeliveryDriver")]
    public string Role { get; set; } = "Customer";
}

public class LoginRequestDto
{
    [Required, EmailAddress, StringLength(120)]
    public string Email { get; set; } = "";

    [Required, StringLength(120, MinimumLength = 8)]
    public string Password { get; set; } = "";
}

public class RefreshTokenRequestDto
{
    [Required, StringLength(200, MinimumLength = 16)]
    public string RefreshToken { get; set; } = "";
}

public class LogoutRequestDto
{
    [Required, StringLength(200, MinimumLength = 16)]
    public string RefreshToken { get; set; } = "";
}
