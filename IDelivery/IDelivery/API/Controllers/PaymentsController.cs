using System.Security.Claims;
using IDelivery.Application.DTOs.Auth;
using IDelivery.Application.DTOs.Customers;
using IDelivery.Application.DTOs.Coupons;
using IDelivery.Application.DTOs.Payments;
using IDelivery.Application.DTOs.Products;
using IDelivery.Application.DTOs.Restaurants;
using IDelivery.Application.IServices;
using IDelivery.Application.UseCases;
using IDelivery.Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IDelivery.Api;
[ApiController, Route("api/payments"), Authorize(Roles = "Customer")]
public class PaymentsController(IPaymentService payments) : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ProcessPaymentRequestDto request) => Ok(await payments.CreateAsync(User.GetUserId(), request));

    [HttpPost("webhook"), AllowAnonymous]
    public async Task<IActionResult> Webhook([FromBody] Guid paymentId)
    {
        Request.Headers.TryGetValue("X-Webhook-Signature", out var providedSignature);
        await payments.ProcessWebhookAsync(paymentId, providedSignature.ToString());
        return Ok();
    }
}

