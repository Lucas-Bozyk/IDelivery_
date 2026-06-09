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
[ApiController, Route("api/restaurants")]
public class RestaurantsController(IRestaurantService restaurants) : ControllerBase
{
    [HttpGet] public async Task<IActionResult> List() => Ok(await restaurants.GetAllAsync());
    [HttpGet("{id:guid}")] public async Task<IActionResult> Get(Guid id) => Ok(await restaurants.GetAsync(id));

    [HttpPost, Authorize(Roles = "Admin,RestaurantOwner")]
    public async Task<IActionResult> Create([FromBody] CreateRestaurantCommand command) =>
        Ok(await restaurants.CreateAsync(User.GetUserId(), User.IsInRole(UserRole.Admin.ToString()), command));

    [HttpPut("{id:guid}"), Authorize(Roles = "Admin,RestaurantOwner")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateRestaurantRequestDto request)
    {
        var updated = await restaurants.UpdateAsync(User.GetUserId(), User.IsInRole(UserRole.Admin.ToString()), id, request);
        if (!updated) return NotFound();
        return NoContent();
    }

    [HttpPatch("{id:guid}/open-status"), Authorize(Roles = "Admin,RestaurantOwner")]
    public async Task<IActionResult> OpenStatus(Guid id, [FromBody] bool isOpen)
    {
        var updated = await restaurants.UpdateOpenStatusAsync(User.GetUserId(), User.IsInRole(UserRole.Admin.ToString()), id, isOpen);
        if (!updated) return NotFound();
        return NoContent();
    }

    [HttpGet("{restaurantId:guid}/products")]
    public async Task<IActionResult> ListProducts(Guid restaurantId) => Ok(await restaurants.GetProductsAsync(restaurantId));

    [HttpPost("{restaurantId:guid}/products"), Authorize(Roles = "Admin,RestaurantOwner")]
    public async Task<IActionResult> CreateProduct(Guid restaurantId, [FromBody] CreateProductRequestDto request) =>
        Ok(await restaurants.CreateProductAsync(User.GetUserId(), User.IsInRole(UserRole.Admin.ToString()), restaurantId, request));

    [HttpGet("{restaurantId:guid}/reviews")]
    public async Task<IActionResult> ListReviews(Guid restaurantId) => Ok(await restaurants.GetReviewsAsync(restaurantId));
}

