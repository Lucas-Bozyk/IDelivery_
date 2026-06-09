using System.ComponentModel.DataAnnotations;

namespace IDelivery.Application.DTOs.Customers;

public class UpdateCustomerMeRequestDto
{
    [Required, StringLength(120, MinimumLength = 2)]
    public string FullName { get; set; } = "";

    [Required, StringLength(20, MinimumLength = 10)]
    public string Phone { get; set; } = "";
}

public class UpsertCustomerAddressRequestDto
{
    [Required, StringLength(120, MinimumLength = 2)]
    public string Street { get; set; } = "";

    [Required, StringLength(20, MinimumLength = 1)]
    public string Number { get; set; } = "";

    [StringLength(120)]
    public string? Complement { get; set; }

    [Required, StringLength(80, MinimumLength = 2)]
    public string Neighborhood { get; set; } = "";

    [Required, StringLength(80, MinimumLength = 2)]
    public string City { get; set; } = "";

    [Required, StringLength(2, MinimumLength = 2)]
    public string State { get; set; } = "";

    [Required, StringLength(12, MinimumLength = 8)]
    public string ZipCode { get; set; } = "";

    public bool IsDefault { get; set; }
}
