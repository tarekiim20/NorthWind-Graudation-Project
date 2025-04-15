FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["NorthWindTraders/NorthWindTraders.csproj", "NorthWindTraders/"]
RUN dotnet restore "NorthWindTraders/NorthWindTraders.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "NorthWindTraders/NorthWindTraders.csproj" -c Release -o /app/build

# Publish
FROM build AS publish
RUN dotnet publish "NorthWindTraders/NorthWindTraders.csproj" -c Release -o /app/publish

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "NorthWindTraders.dll"] 