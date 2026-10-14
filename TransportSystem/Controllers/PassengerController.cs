using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using TransportSystem.UnitOfWork;

namespace TransportSystem.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PassengerController : ControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        public PassengerController(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        [HttpGet("active")]
        public async Task<IActionResult> GetActivePassengers()
        {
           
            var passengers = await _unitOfWork.Passengers.GetActivePassengersAsync();
            return Ok(passengers);
        }

        [HttpDelete("soft-delete/{id}")]
        public async Task<IActionResult> SoftDelete(int id, [FromQuery] string deletedBy = "Admin")
        {
         
            await _unitOfWork.Passengers.SoftDeletePassengerAsync(id, $"'{deletedBy}'");
            return Ok(new { Message = $"Пасажир {id} успішно видалений (Soft Delete) користувачем {deletedBy}" });
        }
    }
}