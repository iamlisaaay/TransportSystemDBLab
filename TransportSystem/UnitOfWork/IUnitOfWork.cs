using TransportSystem.Repositories;

namespace TransportSystem.UnitOfWork
{
    public interface IUnitOfWork : IDisposable
    {
        IPassengerRepository Passengers { get; }
        Task<int> CompleteAsync();
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
    }
}
