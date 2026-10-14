using Microsoft.EntityFrameworkCore;
using TransportSystem.Data;
using TransportSystem.UnitOfWork;

namespace TransportSystem
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

          
            builder.Services.AddDbContext<TransportDbContext>(options =>
                options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

        
            builder.Services.AddScoped<IUnitOfWork, TransportSystem.UnitOfWork.UnitOfWork>();

            builder.Services.AddControllers();

     
            builder.Services.AddEndpointsApiExplorer();
            object value = builder.Services.AddSwaggerGen();

            var app = builder.Build();

         
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI(); 
            }

            app.UseHttpsRedirection();
            app.UseAuthorization();
            app.MapControllers();

            app.Run();
        }
    }
}