using System.ComponentModel.DataAnnotations;

namespace NorthWindTraders.Models
{
    public class Category
    {
        [Key]
        public int CategoryID { get; set; }

        [Required]
        [StringLength(15)]
        public string CategoryName { get; set; }

        public string? Description { get; set; }

        public byte[]? Picture { get; set; }

        // Navigation property
        public virtual ICollection<Product> Products { get; set; }
    }
} 