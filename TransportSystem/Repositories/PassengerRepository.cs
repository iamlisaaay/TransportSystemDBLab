using TransportSystem.Data;
using TransportSystem.Models;
using Microsoft.EntityFrameworkCore;
namespace TransportSystem.Repositories
{
    public class PassengerRepository : IPassengerRepository
    {
        private readonly TransportDbContext _context;

        public PassengerRepository(TransportDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<PassengerTicketDto>> GetActivePassengersAsync()
        {
         
            return await _context.PassengerTickets.FromSqlRaw("SELECT * FROM vw_passengertickets").ToListAsync();
        }

        public async Task SoftDeletePassengerAsync(int passengerId, string deletedBy)
        {
         
            await _context.Database.ExecuteSqlInterpolatedAsync($"CALL sp_SoftDeletePassenger({passengerId}, {deletedBy})");
        }

        public async Task PurchaseTicketAsync(int passengerId, int ticketTypeId, decimal amount)
        {
            await _context.Database.ExecuteSqlInterpolatedAsync($"CALL sp_PurchaseTicket({passengerId}, {ticketTypeId}, {amount})");
        }
    }
}
