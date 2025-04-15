using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NorthWindTraders.Data;
using NorthWindTraders.Models;

namespace NorthWindTraders.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly ApplicationDbContext _context;

    public HomeController(ILogger<HomeController> logger, ApplicationDbContext context)
    {
        _logger = logger;
        _context = context;
    }

    public async Task<IActionResult> Index()
    {
        // Get total counts
        ViewBag.TotalCustomers = await _context.Customers.CountAsync();
        ViewBag.TotalOrders = await _context.Orders.CountAsync();
        ViewBag.TotalProducts = await _context.Products.CountAsync();

        // Calculate total revenue by first getting the order details and then calculating in memory
        var orderDetails = await _context.OrderDetails.ToListAsync();
        ViewBag.TotalRevenue = orderDetails.Sum(od => 
            od.UnitPrice * (decimal)od.Quantity * (1m - (decimal)od.Discount));

        // Get recent orders
        ViewBag.RecentOrders = await _context.Orders
            .Include(o => o.Customer)
            .OrderByDescending(o => o.OrderDate)
            .Take(5)
            .ToListAsync();

        // Get top products
        ViewBag.TopProducts = await _context.Products
            .Include(p => p.Category)
            .OrderByDescending(p => p.UnitsInStock)
            .Take(5)
            .ToListAsync();

        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
