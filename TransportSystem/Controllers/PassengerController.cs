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

        //Отримати список пасажирів
        [HttpGet("active")]
        public async Task<IActionResult> GetActivePassengers()
        {
            var passengers = await _unitOfWork.Passengers.GetActivePassengersAsync();
            return Ok(passengers);
        }

        // Видалити пасажира 
        [HttpDelete("soft-delete/{id}")]
        public async Task<IActionResult> SoftDelete(int id, [FromQuery] string deletedBy = "Admin")
        {
            await _unitOfWork.Passengers.SoftDeletePassengerAsync(id, $"'{deletedBy}'");
            return Ok(new { Message = $"Успіх! Пасажир з ID {id} був видалений (Soft Delete) користувачем {deletedBy}." });
        }

        // Купити квиток 
    
        [HttpPost("purchase-ticket")]
        public async Task<IActionResult> PurchaseTicket(int passengerId, int ticketTypeId, decimal amount)
        {
            try
            {
                await _unitOfWork.Passengers.PurchaseTicketAsync(passengerId, ticketTypeId, amount);
                return Ok(new { Message = $"Успіх! Квиток типу {ticketTypeId} успішно оформлено для пасажира з ID {passengerId} на суму {amount} грн." });
            }
            catch (System.Exception ex)
            {
                
                return BadRequest(new
                {
                    Error = "Операцію відхилено! Можливо, пасажира або типу квитка з таким ID не існує.",
                    DeveloperDetails = ex.InnerException?.Message ?? ex.Message
                });
            }
        }
    }
}