namespace IDelivery.Domain;

public class Delivery : EntityBase
{
    public Guid OrderId { get; set; }
    public Guid? DeliveryDriverId { get; set; }
    public DeliveryStatus Status { get; set; } = DeliveryStatus.Pending;
    public string AddressSnapshot { get; set; } = "";
    public DateTime EstimatedDeliveryTime { get; set; }
    public DateTime? DeliveredAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public void AssignDriver(Guid driverId)
    {
        if (Status is DeliveryStatus.Delivered or DeliveryStatus.Cancelled)
            throw new InvalidOperationException("Entrega finalizada ou cancelada nao pode ser atribuida.");
        DeliveryDriverId = driverId;
        Status = DeliveryStatus.Assigned;
    }

    public void UpdateStatus(DeliveryStatus status, bool paymentApproved)
    {
        if ((status is DeliveryStatus.PickedUp or DeliveryStatus.Delivered) && DeliveryDriverId is null)
            throw new InvalidOperationException("Entrega precisa de entregador atribuido antes de avancar status.");
        if (status == DeliveryStatus.Delivered && !paymentApproved)
            throw new InvalidOperationException("Entrega so pode ser concluida se pagamento estiver aprovado.");
        Status = status;
        if (status == DeliveryStatus.Delivered) DeliveredAt = DateTime.UtcNow;
    }
}
