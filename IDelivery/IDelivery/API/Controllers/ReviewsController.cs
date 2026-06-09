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
[ApiController, Route("api/reviews"), Authorize(Roles = "Customer")]
public class ReviewsController(IReviewService reviews) : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateReviewCommand request)
    {
        return Ok(await reviews.CreateAsync(User.GetUserId(), request));
    }
}

