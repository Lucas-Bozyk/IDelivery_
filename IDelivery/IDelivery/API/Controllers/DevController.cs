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
[ApiController, Route("api/dev"), Authorize(Roles = "Admin")]
public class DevController(IDevValidationService validator) : ControllerBase
{
    [HttpPost("validate-relationships-flow")]
    public async Task<IActionResult> ValidateRelationshipsFlow(CancellationToken ct) => Ok(await validator.ValidateRelationshipsFlowAsync(ct));
}

