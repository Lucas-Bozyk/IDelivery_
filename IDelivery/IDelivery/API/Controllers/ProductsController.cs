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
[ApiController, Route("api/products"), Authorize(Roles = "Admin,RestaurantOwner")]
public class ProductsController(IProductService products) : ControllerBase
{
    [HttpGet("{id:guid}"), AllowAnonymous]
    public async Task<IActionResult> GetById(Guid id)
    {
        var entity = await products.GetByIdAsync(id);
        return entity is null ? NotFound() : Ok(entity);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateProductRequestDto request)
    {
        var updated = await products.UpdateAsync(User.GetUserId(), User.IsInRole(UserRole.Admin.ToString()), id, request);
        if (!updated) return NotFound();
        return NoContent();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var deleted = await products.DeleteAsync(User.GetUserId(), User.IsInRole(UserRole.Admin.ToString()), id);
        if (!deleted) return NotFound();
        return NoContent();
    }
}

