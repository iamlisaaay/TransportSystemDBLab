namespace TransportSystem.Models
{
    public class PassengerTicketDto
    {
        public int ID { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string TicketType { get; set; }
        public DateTime ValidUntil { get; set; }
    }
}
