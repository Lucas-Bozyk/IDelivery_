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
[ApiController, Route("api/deliveries"), Authorize(Roles = "Admin,DeliveryDriver")]
public class DeliveriesController(IDeliveryService deliveries) : ControllerBase
{
    [HttpGet] public async Task<IActionResult> List() => Ok(await deliveries.ListAsync());

    [HttpGet("me"), Authorize(Roles = "DeliveryDriver")]
    public async Task<IActionResult> Mine()
    {
        return Ok(await deliveries.GetMineAsync(User.GetUserId()));
    }

    [HttpPost("dispatch"), Authorize(Roles = "Admin")]
    public async Task<IActionResult> Dispatch() => Ok(await deliveries.DispatchAsync());

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> Status(Guid id, [FromBody] DeliveryStatus status)
    {
        await deliveries.UpdateStatusAsync(User.GetUserId(), User.IsInRole(UserRole.DeliveryDriver.ToString()), id, status);
        return NoContent();
    }

    [HttpPatch("{id:guid}/assign-driver")]
    public async Task<IActionResult> Assign(Guid id, [FromBody] Guid driverId) => Ok(await deliveries.AssignAsync(id, driverId));
}

