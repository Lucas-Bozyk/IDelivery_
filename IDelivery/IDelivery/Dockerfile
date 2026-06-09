FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["IDelivery/IDelivery.csproj", "IDelivery/"]
RUN dotnet restore "IDelivery/IDelivery.csproj"
COPY . .
WORKDIR /src/IDelivery
RUN dotnet publish "IDelivery.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM runtime AS final
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "IDelivery.dll"]
