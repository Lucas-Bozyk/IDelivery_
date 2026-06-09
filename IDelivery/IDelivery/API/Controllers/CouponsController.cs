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
[ApiController, Route("api/coupons")]
public class CouponsController(ICouponService coupons) : ControllerBase
{
    [HttpPost, Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateCouponRequestDto request) => Ok(await coupons.CreateAsync(request));

    [HttpGet("{code}/validate"), AllowAnonymous]
    public async Task<IActionResult> Validate(string code, [FromQuery] decimal orderTotal = 0) => Ok(await coupons.ValidateAsync(code, orderTotal));
}

