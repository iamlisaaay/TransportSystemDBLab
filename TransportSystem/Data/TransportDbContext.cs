using Microsoft.EntityFrameworkCore;
using TransportSystem.Models;

namespace TransportSystem.Data
{
    public class TransportDbContext : DbContext
    {
       
        public TransportDbContext(DbContextOptions<TransportDbContext> options) : base(options) { }

        public DbSet<ActiveVehicleDto> ActiveVehicles { get; set; }
        public DbSet<PassengerTicketDto> PassengerTickets { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<ActiveVehicleDto>().HasNoKey().ToView("vw_activevehicles");
            modelBuilder.Entity<PassengerTicketDto>().HasNoKey().ToView("vw_passengertickets");
        }
    }
}