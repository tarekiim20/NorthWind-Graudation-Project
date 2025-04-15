using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NorthWindTraders.Data;
using NorthWindTraders.Models;

namespace NorthWindTraders.Controllers
{
    public class DashboardController : Controller
    {
        private readonly ApplicationDbContext _context;

        public DashboardController(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            // Overall Statistics
            ViewBag.TotalOrders = await _context.Orders.CountAsync();
            ViewBag.TotalCustomers = await _context.Customers.CountAsync();
            ViewBag.TotalProducts = await _context.Products.CountAsync();
            ViewBag.TotalRevenue = await _context.OrderDetails
                .SumAsync(od => od.UnitPrice * Convert.ToDecimal(od.Quantity) * (1m - Convert.ToDecimal(od.Discount)));

            // Top Customers
            ViewBag.TopCustomers = await _context.Customers
                .Include(c => c.Orders)
                    .ThenInclude(o => o.OrderDetails)
                .Select(c => new
                {
                    c.CompanyName,
                    TotalOrders = c.Orders.Count,
                    TotalSpent = c.Orders.SelectMany(o => o.OrderDetails)
                        .Sum(od => od.UnitPrice * Convert.ToDecimal(od.Quantity) * (1m - Convert.ToDecimal(od.Discount)))
                })
                .OrderByDescending(c => c.TotalSpent)
                .Take(5)
                .ToListAsync();

            // Top Products
            ViewBag.TopProducts = await _context.Products
                .Include(p => p.OrderDetails)
                .Select(p => new
                {
                    p.ProductName,
                    TotalRevenue = p.OrderDetails.Sum(od => od.UnitPrice * Convert.ToDecimal(od.Quantity) * (1m - Convert.ToDecimal(od.Discount))),
                    p.UnitsInStock
                })
                .OrderByDescending(p => p.TotalRevenue)
                .Take(5)
                .ToListAsync();

            // Recent Orders
            ViewBag.RecentOrders = await _context.Orders
                .Include(o => o.Customer)
                .OrderByDescending(o => o.OrderDate)
                .Take(10)
                .ToListAsync();

            // Monthly Revenue - Simplified query
            var orders = await _context.Orders
                .Include(o => o.OrderDetails)
                .Where(o => o.OrderDate != null)
                .ToListAsync();

            var monthlyRevenue = orders
                .GroupBy(o => new { o.OrderDate.Value.Year, o.OrderDate.Value.Month })
                .Select(g => new
                {
                    Date = new DateTime(g.Key.Year, g.Key.Month, 1),
                    Revenue = g.SelectMany(o => o.OrderDetails)
                        .Sum(od => od.UnitPrice * Convert.ToDecimal(od.Quantity) * (1m - Convert.ToDecimal(od.Discount)))
                })
                .OrderByDescending(x => x.Date)
                .Take(12)
                .OrderBy(x => x.Date)
                .ToList();

            ViewBag.MonthlyRevenue = monthlyRevenue;

            // Orders by Region for Map
            var ordersByRegion = await _context.Orders
                .Include(o => o.OrderDetails)
                .Include(o => o.Customer)
                .Where(o => o.ShipCity != null)
                .GroupBy(o => new { o.ShipCity, o.ShipCountry })
                .Select(g => new
                {
                    City = g.Key.ShipCity,
                    Country = g.Key.ShipCountry,
                    OrderCount = g.Count(),
                    TotalRevenue = g.SelectMany(o => o.OrderDetails)
                        .Sum(od => od.UnitPrice * Convert.ToDecimal(od.Quantity) * (1m - Convert.ToDecimal(od.Discount)))
                })
                .ToListAsync();

            // Add approximate coordinates for major cities
            var ordersWithCoordinates = ordersByRegion.Select(o => new
            {
                o.City,
                o.Country,
                o.OrderCount,
                o.TotalRevenue,
                // Approximate coordinates for major cities
                Latitude = GetApproximateLatitude(o.City),
                Longitude = GetApproximateLongitude(o.City)
            }).ToList();

            ViewBag.OrdersByRegion = ordersWithCoordinates;

            return View();
        }

        private double GetApproximateLatitude(string city)
        {
            // Approximate coordinates for major cities
            return city?.ToLower() switch
            {
                "london" => 51.5074,
                "paris" => 48.8566,
                "berlin" => 52.5200,
                "madrid" => 40.4168,
                "rome" => 41.9028,
                "vienna" => 48.2082,
                "amsterdam" => 52.3676,
                "brussels" => 50.8503,
                "copenhagen" => 55.6761,
                "stockholm" => 59.3293,
                "oslo" => 59.9139,
                "helsinki" => 60.1699,
                "dublin" => 53.3498,
                "lisbon" => 38.7223,
                "athens" => 37.9838,
                "prague" => 50.0755,
                "warsaw" => 52.2297,
                "budapest" => 47.4979,
                "bucharest" => 44.4268,
                "sofia" => 42.6977,
                _ => 0
            };
        }

        private double GetApproximateLongitude(string city)
        {
            // Approximate coordinates for major cities
            return city?.ToLower() switch
            {
                "london" => -0.1278,
                "paris" => 2.3522,
                "berlin" => 13.4050,
                "madrid" => -3.7038,
                "rome" => 12.4964,
                "vienna" => 16.3738,
                "amsterdam" => 4.9041,
                "brussels" => 4.3517,
                "copenhagen" => 12.5683,
                "stockholm" => 18.0686,
                "oslo" => 10.7522,
                "helsinki" => 24.9384,
                "dublin" => -6.2603,
                "lisbon" => -9.1393,
                "athens" => 23.7275,
                "prague" => 14.4378,
                "warsaw" => 21.0178,
                "budapest" => 19.0402,
                "bucharest" => 26.1025,
                "sofia" => 23.3219,
                _ => 0
            };
        }
    }
} 