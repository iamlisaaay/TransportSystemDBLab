using Microsoft.EntityFrameworkCore.Storage;
using TransportSystem.Data;
using TransportSystem.Repositories;

namespace TransportSystem.UnitOfWork
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly TransportDbContext _context;
        private IDbContextTransaction _transaction;

        public IPassengerRepository Passengers { get; private set; }

        public UnitOfWork(TransportDbContext context)
        {
            _context = context;
            Passengers = new PassengerRepository(_context);
        }

        public async Task BeginTransactionAsync()
        {
            _transaction = await _context.Database.BeginTransactionAsync();
        }

        public async Task CommitTransactionAsync()
        {
            await _transaction?.CommitAsync();
        }

        public async Task RollbackTransactionAsync()
        {
            await _transaction?.RollbackAsync();
        }

        public async Task<int> CompleteAsync()
        {
           
            return await _context.SaveChangesAsync();
        }

        public void Dispose()
        {
            _transaction?.Dispose();
            _context.Dispose();
        }
    }
}
