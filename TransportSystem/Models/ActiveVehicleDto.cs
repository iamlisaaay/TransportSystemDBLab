namespace TransportSystem.Models
{
    public class ActiveVehicleDto
    {
        public int ID { get; set; }
        public string VIN { get; set; }
        public string TransportType { get; set; }
        public int Capacity { get; set; }
        public string Status { get; set; }
    }
}
