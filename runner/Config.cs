using System.Text.Json;

namespace WWSmokeRunner;

// Loads appsettings.json from next to the executable. Secrets are NOT here -
// PAT and SMTP password come from environment variables at runtime.
internal sealed class Config
{
    public required string Org { get; init; }
    public required string Project { get; init; }
    public required int PipelineId { get; init; }
    public required string SourceBranch { get; init; }

    public required string DefaultEnvironment { get; init; }
    public required string DefaultBrowser { get; init; }
    public required int DefaultMaxParallel { get; init; }
    public required string[] Environments { get; init; }
    public required string[] Browsers { get; init; }

    public bool EmailEnabled { get; init; }
    public string SmtpHost { get; init; } = "";
    public int SmtpPort { get; init; } = 25;
    public bool SmtpUseSsl { get; init; }
    public string EmailFrom { get; init; } = "";
    public string DefaultTo { get; init; } = "";

    public static Config Load()
    {
        var path = Path.Combine(AppContext.BaseDirectory, "appsettings.json");
        if (!File.Exists(path))
            throw new FileNotFoundException($"appsettings.json not found next to the exe ({path}).");

        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        var root = doc.RootElement;
        var ado = root.GetProperty("Ado");
        var def = root.GetProperty("Defaults");
        var email = root.TryGetProperty("Email", out var e) ? e : default;

        string S(JsonElement el, string name, string fallback = "") =>
            el.ValueKind == JsonValueKind.Object && el.TryGetProperty(name, out var v) ? v.GetString() ?? fallback : fallback;
        int I(JsonElement el, string name, int fallback) =>
            el.ValueKind == JsonValueKind.Object && el.TryGetProperty(name, out var v) ? v.GetInt32() : fallback;
        bool B(JsonElement el, string name, bool fallback) =>
            el.ValueKind == JsonValueKind.Object && el.TryGetProperty(name, out var v) ? v.GetBoolean() : fallback;
        string[] A(string name) =>
            root.TryGetProperty(name, out var v) && v.ValueKind == JsonValueKind.Array
                ? v.EnumerateArray().Select(x => x.GetString() ?? "").Where(s => s.Length > 0).ToArray()
                : Array.Empty<string>();

        return new Config
        {
            Org = S(ado, "Org"),
            Project = S(ado, "Project"),
            PipelineId = I(ado, "PipelineId", 0),
            SourceBranch = S(ado, "SourceBranch", "refs/heads/main"),
            DefaultEnvironment = S(def, "Environment", "TS06"),
            DefaultBrowser = S(def, "Browser", "msedge"),
            DefaultMaxParallel = I(def, "MaxParallel", 3),
            Environments = A("Environments"),
            Browsers = A("Browsers"),
            EmailEnabled = B(email, "Enabled", false),
            SmtpHost = S(email, "SmtpHost"),
            SmtpPort = I(email, "SmtpPort", 25),
            SmtpUseSsl = B(email, "UseSsl", false),
            EmailFrom = S(email, "From"),
            DefaultTo = S(email, "DefaultTo"),
        };
    }
}
