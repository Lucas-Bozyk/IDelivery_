using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IDelivery.Persistence.Migrations.Delivery
{
    /// <inheritdoc />
    public partial class AddRestaurantProfileImageUrl : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ProfileImageUrl",
                table: "Restaurants",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ProfileImageUrl",
                table: "Restaurants");
        }
    }
}
