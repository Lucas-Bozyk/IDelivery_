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
[ApiController, Route("api/cart"), Authorize(Roles = "Customer")]
public class CartController(ICartService cartService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Get()
    {
        return Ok(await cartService.GetActiveCartAsync(User.GetUserId()));
    }

    [HttpPost("items")]
    public async Task<IActionResult> AddItem([FromBody] AddProductToCartCommand request)
    {
        return Ok(await cartService.AddItemAsync(User.GetUserId(), request));
    }

    [HttpPut("items/{id:guid}")]
    public async Task<IActionResult> UpdateItem(Guid id, [FromBody] int quantity)
    {
        var updated = await cartService.UpdateItemAsync(User.GetUserId(), id, quantity);
        if (!updated) return NotFound();
        return NoContent();
    }

    [HttpDelete("items/{id:guid}")]
    public async Task<IActionResult> RemoveItem(Guid id)
    {
        var removed = await cartService.RemoveItemAsync(User.GetUserId(), id);
        if (!removed) return NotFound();
        return NoContent();
    }

    [HttpDelete]
    public async Task<IActionResult> Clear()
    {
        await cartService.ClearAsync(User.GetUserId());
        return NoContent();
    }
}

