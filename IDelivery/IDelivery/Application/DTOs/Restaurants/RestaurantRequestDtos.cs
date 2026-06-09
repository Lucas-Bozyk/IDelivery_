using System.ComponentModel.DataAnnotations;

namespace IDelivery.Application.DTOs.Restaurants;

public class UpdateRestaurantRequestDto
{
    [Required, StringLength(120, MinimumLength = 2)]
    public string Name { get; set; } = "";

    [Required, StringLength(500, MinimumLength = 2)]
    public string Description { get; set; } = "";

    [Required, StringLength(18, MinimumLength = 14)]
    public string Cnpj { get; set; } = "";

    [Required, StringLength(20, MinimumLength = 10)]
    public string Phone { get; set; } = "";

    [Required, EmailAddress, StringLength(120)]
    public string Email { get; set; } = "";

    [StringLength(500)]
    public string? ProfileImageUrl { get; set; }

    [Required]
    public Guid CategoryId { get; set; }
}
