using TransportSystem.Models;

namespace TransportSystem.Repositories
{
    public interface IPassengerRepository
    {
        Task<IEnumerable<PassengerTicketDto>> GetActivePassengersAsync();
        Task SoftDeletePassengerAsync(int passengerId, string deletedBy);
        Task PurchaseTicketAsync(int passengerId, int ticketTypeId, decimal amount);
    }
}
