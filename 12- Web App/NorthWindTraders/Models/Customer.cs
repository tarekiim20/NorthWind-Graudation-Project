using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NorthWindTraders.Models
{
    [Table("Customers")]
    public class Customer
    {
        [Key]
        [Required]
        [StringLength(5)]
        public string CustomerID { get; set; } = string.Empty;

        [Required]
        [StringLength(40)]
        public string CompanyName { get; set; } = string.Empty;

        [StringLength(30)]
        public string? ContactName { get; set; }

        [StringLength(30)]
        public string? ContactTitle { get; set; }

        [StringLength(60)]
        public string? Address { get; set; }

        [StringLength(15)]
        public string? City { get; set; }

        [StringLength(15)]
        public string? Region { get; set; }

        [StringLength(10)]
        public string? PostalCode { get; set; }

        [StringLength(15)]
        public string? Country { get; set; }

        [StringLength(24)]
        public string? Phone { get; set; }

        [StringLength(24)]
        public string? Fax { get; set; }

        // Navigation property
        public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
    }
} 