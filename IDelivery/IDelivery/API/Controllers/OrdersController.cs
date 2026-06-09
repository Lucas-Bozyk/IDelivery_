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
[ApiController, Route("api/orders")]
public class OrdersController(IOrderService service) : ControllerBase
{
    [HttpPost]
    [Authorize(Roles = "Customer")]
    public async Task<IActionResult> Create([FromBody] Guid? couponId)
    {
        return Ok(await service.CreateAsync(User.GetUserId(), couponId));
    }

    [HttpGet]
    [Authorize(Roles = "Customer")]
    public async Task<IActionResult> List()
    {
        return Ok(await service.GetByCustomerUserAsync(User.GetUserId()));
    }

    [HttpGet("restaurant/{restaurantId:guid}")]
    [Authorize(Roles = "Admin,RestaurantOwner")]
    public async Task<IActionResult> ListByRestaurant(Guid restaurantId)
    {
        return Ok(await service.GetByRestaurantAsync(User.GetUserId(), User.IsInRole(UserRole.Admin.ToString()), restaurantId));
    }

    [HttpGet("restaurant/{restaurantId:guid}/{orderId:guid}")]
    [Authorize(Roles = "Admin,RestaurantOwner")]
    public async Task<IActionResult> GetRestaurantOrder(Guid restaurantId, Guid orderId)
    {
        var details = await service.GetRestaurantOrderAsync(User.GetUserId(), User.IsInRole(UserRole.Admin.ToString()), restaurantId, orderId);
        return details is null ? NotFound() : Ok(details);
    }

    [HttpGet("{id:guid}")]
    [Authorize(Roles = "Customer")]
    public async Task<IActionResult> Get(Guid id)
    {
        var order = await service.GetCustomerOrderAsync(User.GetUserId(), id);
        return order is null ? NotFound() : Ok(order);
    }

    [HttpPatch("{id:guid}/status"), Authorize(Roles = "Admin,RestaurantOwner")]
    public async Task<IActionResult> Status(Guid id, [FromBody] OrderStatus status) { await service.UpdateStatusAsync(User.GetUserId(), User.IsInRole(UserRole.Admin.ToString()), id, status); return NoContent(); }

    [HttpPost("{id:guid}/cancel")]
    [Authorize(Roles = "Customer")]
    public async Task<IActionResult> Cancel(Guid id)
    {
        var cancelled = await service.CancelAsync(User.GetUserId(), id);
        if (!cancelled) return NotFound();
        return NoContent();
    }
}

