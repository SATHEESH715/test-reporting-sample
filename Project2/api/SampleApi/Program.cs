var builder = WebApplication.CreateBuilder(args);
builder.Services.AddCors(o => o.AddDefaultPolicy(p => p.WithOrigins("http://localhost:4201").AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();
app.UseCors();

app.MapGet("/api/tenancies", () => TenancyData.GetAll());
app.MapGet("/api/health", () => Results.Ok(new { status = "ok" }));

app.Run();

public record TenancyItem(Guid Id, int TenancyNumber, string Tenant, string Property, string Status);

public static class TenancyData
{
    public static IReadOnlyList<TenancyItem> GetAll() =>
    [
        new(Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), 2001, "A Patel", "1 High Street, Leeds", "Active"),
        new(Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), 2002, "B Jones", "3 Park Road, Hull", "Active"),
        new(Guid.Parse("cccccccc-cccc-cccc-cccc-cccccccccccc"), 2003, "C Smith", "5 Station Road, Leeds", "Ended"),
    ];
}
