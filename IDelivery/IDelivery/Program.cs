using System.Text;
using Asp.Versioning;
using IDelivery.Api;
using IDelivery.Application;
using IDelivery.Domain;
using IDelivery.Infrastructure.Config;
using IDelivery.Infrastructure;
using IDelivery.Infrastructure.Security;
using IDelivery.Persistence;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Threading.RateLimiting;

DotEnvLoader.Load(Path.Combine(AppContext.BaseDirectory, ".env"));
DotEnvLoader.Load(Path.Combine(Directory.GetCurrentDirectory(), ".env"));

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.AddPolicy("AuthLogin", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(BuildAuthPartitionKey(httpContext, "login"), _ => new FixedWindowRateLimiterOptions
        {
            PermitLimit = builder.Configuration.GetValue("RateLimiting:AuthLogin:PermitLimit", 5),
            Window = TimeSpan.FromMinutes(builder.Configuration.GetValue("RateLimiting:AuthLogin:WindowMinutes", 1)),
            QueueLimit = 0,
            AutoReplenishment = true
        }));
    options.AddPolicy("AuthRegister", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(BuildAuthPartitionKey(httpContext, "register"), _ => new FixedWindowRateLimiterOptions
        {
            PermitLimit = builder.Configuration.GetValue("RateLimiting:AuthRegister:PermitLimit", 3),
            Window = TimeSpan.FromMinutes(builder.Configuration.GetValue("RateLimiting:AuthRegister:WindowMinutes", 5)),
            QueueLimit = 0,
            AutoReplenishment = true
        }));
    options.AddPolicy("AuthRefresh", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(BuildAuthPartitionKey(httpContext, "refresh"), _ => new FixedWindowRateLimiterOptions
        {
            PermitLimit = builder.Configuration.GetValue("RateLimiting:AuthRefresh:PermitLimit", 10),
            Window = TimeSpan.FromMinutes(builder.Configuration.GetValue("RateLimiting:AuthRefresh:WindowMinutes", 1)),
            QueueLimit = 0,
            AutoReplenishment = true
        }));
});
builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendLocal", policy =>
    {
        var allowedOrigins = builder.Configuration["Cors:AllowedOrigins"]?
            .Split([';', ','], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        if (allowedOrigins is null || allowedOrigins.Length == 0)
            throw new InvalidOperationException("Cors__AllowedOrigins must be configured via environment.");
        policy
            .WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});
builder.Services.AddApiVersioning(o =>
{
    o.DefaultApiVersion = new ApiVersion(1, 0);
    o.AssumeDefaultVersionWhenUnspecified = true;
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<IdentityDbContext>(o => o.UseNpgsql(builder.Configuration.GetConnectionString("IdentityDb")));
builder.Services.AddDbContext<DeliveryDbContext>(o => o.UseNpgsql(builder.Configuration.GetConnectionString("DeliveryDb")));
builder.Services.AddPersistence();
builder.Services.AddApplication();
builder.Services.AddInfrastructure();
var jwt = builder.Configuration.GetSection("Jwt");
if (string.IsNullOrWhiteSpace(jwt["Key"]) || jwt["Key"]!.Length < 32)
    throw new InvalidOperationException("JWT key must be configured via environment (Jwt__Key) with at least 32 chars.");
if (string.IsNullOrWhiteSpace(jwt["Issuer"]) || string.IsNullOrWhiteSpace(jwt["Audience"]))
    throw new InvalidOperationException("JWT issuer/audience must be configured via environment (Jwt__Issuer, Jwt__Audience).");
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwt["Issuer"],
            ValidAudience = jwt["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt["Key"]!))
        };
    });
builder.Services.AddAuthorization();

var app = builder.Build();
if (!app.Environment.IsEnvironment("Testing"))
{
    using (var scope = app.Services.CreateScope())
    {
        var identityDb = scope.ServiceProvider.GetRequiredService<IdentityDbContext>();
        var deliveryDb = scope.ServiceProvider.GetRequiredService<DeliveryDbContext>();
        identityDb.Database.Migrate();
        deliveryDb.Database.Migrate();
        foreach (var role in Enum.GetValues<UserRole>())
        {
            if (!identityDb.Roles.Any(x => x.Name == role)) identityDb.Roles.Add(new Role { Name = role });
        }
        SeedUserByRole(identityDb, deliveryDb, UserRole.Admin, "ADMIN_EMAIL", "ADMIN_PASSWORD");
        SeedUserByRole(identityDb, deliveryDb, UserRole.Customer, "CUSTOMER_EMAIL", "CUSTOMER_PASSWORD");
        SeedUserByRole(identityDb, deliveryDb, UserRole.DeliveryDriver, "DELIVERY_DRIVER_EMAIL", "DELIVERY_DRIVER_PASSWORD");
        identityDb.SaveChanges();
    }
}
app.UseMiddleware<GlobalExceptionMiddleware>();
app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FrontendLocal");
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();

static void SeedUserByRole(
    IdentityDbContext identityDb,
    DeliveryDbContext deliveryDb,
    UserRole role,
    string emailEnv,
    string passwordEnv)
{
    var email = Environment.GetEnvironmentVariable(emailEnv);
    var password = Environment.GetEnvironmentVariable(passwordEnv);
    if (string.IsNullOrWhiteSpace(email)) return;
    if (string.IsNullOrWhiteSpace(password) || password.Length < 12)
        throw new InvalidOperationException($"{passwordEnv} must be set with at least 12 chars.");
    email = email.Trim().ToLowerInvariant();
    var user = identityDb.Users.FirstOrDefault(x => x.Email == email);
    if (user is null)
    {
        user = new User
        {
            Name = email.Split('@')[0],
            Email = email,
            PasswordHash = PasswordHasher.HashPassword(password)
        };
        identityDb.Users.Add(user);
        identityDb.SaveChanges();
    }

    var roleEntity = identityDb.Roles.First(x => x.Name == role);
    if (!identityDb.UserRoles.Any(x => x.UserId == user.Id && x.RoleId == roleEntity.Id))
    {
        identityDb.UserRoles.Add(new UserRoleMap { UserId = user.Id, RoleId = roleEntity.Id });
        identityDb.SaveChanges();
    }

    if (role == UserRole.Customer)
    {
        var customer = deliveryDb.Customers.FirstOrDefault(x => x.UserId == user.Id);
        if (customer is null)
        {
            customer = new Customer
            {
                UserId = user.Id,
                FullName = email.Split('@')[0],
                Phone = "11999999999"
            };
            deliveryDb.Customers.Add(customer);
            deliveryDb.SaveChanges();
        }
        if (user.CustomerId != customer.Id)
        {
            user.CustomerId = customer.Id;
            identityDb.Users.Update(user);
            identityDb.SaveChanges();
        }
    }
    else if (role == UserRole.DeliveryDriver)
    {
        DeliveryDriver? driver = null;
        if (user.DeliveryDriverId.HasValue)
            driver = deliveryDb.DeliveryDrivers.FirstOrDefault(x => x.Id == user.DeliveryDriverId.Value);
        driver ??= deliveryDb.DeliveryDrivers.FirstOrDefault(x => x.Name == email);
        if (driver is null)
        {
            driver = new DeliveryDriver { Name = email };
            deliveryDb.DeliveryDrivers.Add(driver);
            deliveryDb.SaveChanges();
        }
        if (user.DeliveryDriverId != driver.Id)
        {
            user.DeliveryDriverId = driver.Id;
            identityDb.Users.Update(user);
            identityDb.SaveChanges();
        }
    }
}

static string BuildAuthPartitionKey(HttpContext context, string endpoint)
{
    var ip = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
    var email = context.Request.HasJsonContentType()
        ? context.Request.Query["email"].ToString()
        : "";
    return $"{endpoint}:{ip}:{email.Trim().ToLowerInvariant()}";
}

public partial class Program { }
