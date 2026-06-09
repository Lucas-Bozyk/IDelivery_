using IDelivery.Domain;
using IDelivery.Application.Ports;

namespace IDelivery.Application.UseCases;

public record CreateReviewCommand(Guid CustomerId, Guid OrderId, int Rating, string Comment);

public class CreateReviewUseCase(IReviewRepository repository)
{
    public async Task<Review> ExecuteAsync(CreateReviewCommand command, CancellationToken ct = default)
    {
        var order = await repository.GetCustomerOrderAsync(command.CustomerId, command.OrderId, ct)
            ?? throw new InvalidOperationException("Order not found.");
        var review = Review.Create(command.CustomerId, order, command.Rating, command.Comment);
        await repository.AddReviewAsync(review, ct);
        await repository.SaveChangesAsync(ct);
        return review;
    }
}
