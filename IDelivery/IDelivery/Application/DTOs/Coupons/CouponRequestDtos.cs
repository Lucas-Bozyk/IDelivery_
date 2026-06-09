using System.ComponentModel.DataAnnotations;
using IDelivery.Domain;

namespace IDelivery.Application.DTOs.Coupons;

public class CreateCouponRequestDto
{
    [Required, StringLength(40, MinimumLength = 3)]
    public string Code { get; set; } = "";

    [Required]
    public DiscountType DiscountType { get; set; }

    [Range(0.01, 1000000)]
    public decimal Value { get; set; }

    [Range(0, 1000000)]
    public decimal MinValue { get; set; }

    [Required]
    public DateTime ExpirationDate { get; set; }

    [Range(1, int.MaxValue)]
    public int UsageLimit { get; set; }
}
