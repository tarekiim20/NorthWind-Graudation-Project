using Microsoft.EntityFrameworkCore;
using NorthWindTraders.Models;

namespace NorthWindTraders.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Customer> Customers { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderDetail> OrderDetails { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<Category> Categories { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure tables with their schemas
            modelBuilder.Entity<Customer>(entity =>
            {
                entity.ToTable("Customers");
                entity.Property(e => e.CustomerID).HasColumnName("CustomerID");
                entity.Property(e => e.CompanyName).HasColumnName("CompanyName");
                entity.Property(e => e.ContactName).HasColumnName("ContactName");
                entity.Property(e => e.ContactTitle).HasColumnName("ContactTitle");
                entity.Property(e => e.Address).HasColumnName("Address");
                entity.Property(e => e.City).HasColumnName("City");
                entity.Property(e => e.Region).HasColumnName("Region");
                entity.Property(e => e.PostalCode).HasColumnName("PostalCode");
                entity.Property(e => e.Country).HasColumnName("Country");
                entity.Property(e => e.Phone).HasColumnName("Phone");
                entity.Property(e => e.Fax).HasColumnName("Fax");
            });

            modelBuilder.Entity<Order>(entity =>
            {
                entity.ToTable("Orders");
                entity.Property(e => e.OrderID).HasColumnName("OrderID");
                entity.Property(e => e.CustomerID).HasColumnName("CustomerID");
                entity.Property(e => e.EmployeeID).HasColumnName("EmployeeID");
                entity.Property(e => e.OrderDate).HasColumnName("OrderDate");
                entity.Property(e => e.RequiredDate).HasColumnName("RequiredDate");
                entity.Property(e => e.ShippedDate).HasColumnName("ShippedDate");
                entity.Property(e => e.ShipVia).HasColumnName("ShipVia");
                entity.Property(e => e.Freight).HasColumnName("Freight");
                entity.Property(e => e.ShipName).HasColumnName("ShipName");
                entity.Property(e => e.ShipAddress).HasColumnName("ShipAddress");
                entity.Property(e => e.ShipCity).HasColumnName("ShipCity");
                entity.Property(e => e.ShipRegion).HasColumnName("ShipRegion");
                entity.Property(e => e.ShipPostalCode).HasColumnName("ShipPostalCode");
                entity.Property(e => e.ShipCountry).HasColumnName("ShipCountry");
            });

            // Configure relationships
            modelBuilder.Entity<Order>()
                .HasOne(o => o.Customer)
                .WithMany(c => c.Orders)
                .HasForeignKey(o => o.CustomerID);

            modelBuilder.Entity<OrderDetail>()
                .HasKey(od => new { od.OrderID, od.ProductID });

            modelBuilder.Entity<OrderDetail>()
                .HasOne(od => od.Order)
                .WithMany(o => o.OrderDetails)
                .HasForeignKey(od => od.OrderID);

            modelBuilder.Entity<OrderDetail>()
                .HasOne(od => od.Product)
                .WithMany(p => p.OrderDetails)
                .HasForeignKey(od => od.ProductID);

            modelBuilder.Entity<Product>()
                .HasOne(p => p.Category)
                .WithMany(c => c.Products)
                .HasForeignKey(p => p.CategoryID);
        }
    }
} 