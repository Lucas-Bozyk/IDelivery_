using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IDelivery.Persistence.Migrations.Delivery
{
    /// <inheritdoc />
    public partial class AddCommentToCartItem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Comment",
                table: "CartItems",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Comment",
                table: "CartItems");
        }
    }
}
