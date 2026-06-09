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

namespace IDelivery.Api;
[ApiController, Route("api/customers"), Authorize(Roles = "Customer")]
public class CustomersController(ICustomerService customers) : ControllerBase
{
    [HttpGet("me")]
    public async Task<IActionResult> Me()
    {
        var userId = User.GetUserId();
        var customer = await customers.GetMeAsync(userId);
        return customer is null ? NotFound() : Ok(customer);
    }

    [HttpPut("me")]
    public async Task<IActionResult> UpdateMe([FromBody] UpdateCustomerMeRequestDto request)
    {
        var userId = User.GetUserId();
        var customer = await customers.UpdateMeAsync(userId, request);
        if (customer is null) return NotFound();
        return NoContent();
    }

    [HttpPost("addresses")]
    public async Task<IActionResult> AddAddress([FromBody] UpsertCustomerAddressRequestDto request)
    {
        var userId = User.GetUserId();
        return Ok(await customers.AddAddressAsync(userId, request));
    }

    [HttpGet("addresses")]
    public async Task<IActionResult> GetAddresses()
    {
        var userId = User.GetUserId();
        return Ok(await customers.GetAddressesAsync(userId));
    }

    [HttpPut("addresses/{id:guid}")]
    public async Task<IActionResult> UpdateAddress(Guid id, [FromBody] UpsertCustomerAddressRequestDto request)
    {
        var userId = User.GetUserId();
        var updated = await customers.UpdateAddressAsync(userId, id, request);
        if (!updated) return NotFound();
        return NoContent();
    }

    [HttpDelete("addresses/{id:guid}")]
    public async Task<IActionResult> DeleteAddress(Guid id)
    {
        var userId = User.GetUserId();
        var deleted = await customers.DeleteAddressAsync(userId, id);
        if (!deleted) return NotFound();
        return NoContent();
    }
}

