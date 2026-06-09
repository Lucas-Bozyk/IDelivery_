using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IDelivery.Persistence.Migrations.Identity
{
    /// <inheritdoc />
    public partial class AddRestaurantIdToIdentityUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "RestaurantId",
                table: "Users",
                type: "uuid",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "RestaurantId",
                table: "Users");
        }
    }
}
