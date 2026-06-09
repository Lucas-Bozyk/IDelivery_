using System.ComponentModel.DataAnnotations;

namespace IDelivery.Application.DTOs.Products;

public class CreateProductRequestDto
{
    [Required]
    public Guid MenuCategoryId { get; set; }

    [Required, StringLength(120, MinimumLength = 2)]
    public string Name { get; set; } = "";

    [Required, StringLength(500, MinimumLength = 2)]
    public string Description { get; set; } = "";

    [Range(0.01, 1000000)]
    public decimal Price { get; set; }

    public decimal? PromotionalPrice { get; set; }

    public bool IsAvailable { get; set; }

    [StringLength(500)]
    public string? ImageUrl { get; set; }
}

public class UpdateProductRequestDto
{
    [Required]
    public Guid MenuCategoryId { get; set; }

    [Required, StringLength(120, MinimumLength = 2)]
    public string Name { get; set; } = "";

    [Required, StringLength(500, MinimumLength = 2)]
    public string Description { get; set; } = "";

    [Range(0.01, 1000000)]
    public decimal Price { get; set; }

    public decimal? PromotionalPrice { get; set; }

    public bool IsAvailable { get; set; }

    [StringLength(500)]
    public string? ImageUrl { get; set; }
}
