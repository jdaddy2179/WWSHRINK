using System.IO.Compression;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace WWSmokeRunner;

internal sealed record QueuedBuild(int Id, string BuildNumber, string WebUrl);
internal sealed record BuildState(string Status, string? Result);
internal sealed record ReportFile(string Html, string HtmlPath);

// Thin Azure DevOps REST client (Build API) using PAT basic auth.
internal sealed class AdoClient
{
    private readonly HttpClient _http = new();
    private readonly string _base; // https://dev.azure.com/{org}/{project}

    public AdoClient(string org, string project, string pat)
    {
        _base = $"https://dev.azure.com/{Uri.EscapeDataString(org)}/{Uri.EscapeDataString(project)}";
        var basic = Convert.ToBase64String(Encoding.ASCII.GetBytes(":" + pat));
        _http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", basic);
        _http.Timeout = TimeSpan.FromSeconds(100);
    }

    public async Task<QueuedBuild> QueueAsync(int pipelineId, string sourceBranch, string env, string browser, int maxParallel)
    {
        var payload = JsonSerializer.Serialize(new
        {
            definition = new { id = pipelineId },
            templateParameters = new { testEnv = env, browserChannel = browser, maxParallel },
            sourceBranch,
        });
        using var content = new StringContent(payload, Encoding.UTF8, "application/json");
        using var resp = await _http.PostAsync($"{_base}/_apis/build/builds?api-version=7.0", content);
        var json = await resp.Content.ReadAsStringAsync();
        if (!resp.IsSuccessStatusCode)
            throw new InvalidOperationException($"Queue failed ({(int)resp.StatusCode}): {Extract(json, "message") ?? json}");

        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;
        var id = root.GetProperty("id").GetInt32();
        var num = root.TryGetProperty("buildNumber", out var bn) ? bn.GetString() ?? id.ToString() : id.ToString();
        var web = root.TryGetProperty("_links", out var l) && l.TryGetProperty("web", out var w) &&
                  w.TryGetProperty("href", out var h) ? h.GetString() ?? "" : "";
        return new QueuedBuild(id, num, web);
    }

    public async Task<BuildState> GetAsync(int id)
    {
        var json = await _http.GetStringAsync($"{_base}/_apis/build/builds/{id}?api-version=7.0");
        using var doc = JsonDocument.Parse(json);
        var r = doc.RootElement;
        return new BuildState(
            r.GetProperty("status").GetString() ?? "unknown",
            r.TryGetProperty("result", out var res) ? res.GetString() : null);
    }

    public async Task<BuildState> WaitAsync(int id, TimeSpan timeout, Action<string>? onTick = null)
    {
        var deadline = DateTime.UtcNow + timeout;
        while (true)
        {
            var s = await GetAsync(id);
            onTick?.Invoke(s.Status);
            if (string.Equals(s.Status, "completed", StringComparison.OrdinalIgnoreCase))
                return s;
            if (DateTime.UtcNow > deadline)
                throw new TimeoutException($"Build {id} did not finish within {timeout.TotalMinutes:0} minutes.");
            await Task.Delay(TimeSpan.FromSeconds(20));
        }
    }

    // Downloads the WW-Smoke-Report-<ENV> artifact and extracts the HTML report.
    // Returns null if the artifact isn't present (e.g. the report job was skipped).
    public async Task<ReportFile?> TryDownloadReportAsync(int id, string env)
    {
        var artifactName = $"WW-Smoke-Report-{env}";
        var metaUrl = $"{_base}/_apis/build/builds/{id}/artifacts?artifactName={Uri.EscapeDataString(artifactName)}&api-version=7.0";
        using var metaResp = await _http.GetAsync(metaUrl);
        if (!metaResp.IsSuccessStatusCode) return null;

        var meta = await metaResp.Content.ReadAsStringAsync();
        string? downloadUrl;
        try
        {
            using var doc = JsonDocument.Parse(meta);
            downloadUrl = doc.RootElement.TryGetProperty("resource", out var r) &&
                          r.TryGetProperty("downloadUrl", out var d) ? d.GetString() : null;
        }
        catch { return null; }
        if (string.IsNullOrWhiteSpace(downloadUrl)) return null;

        var zipBytes = await _http.GetByteArrayAsync(downloadUrl);
        using var zip = new ZipArchive(new MemoryStream(zipBytes), ZipArchiveMode.Read);
        var entry = zip.Entries.FirstOrDefault(e => e.Name.EndsWith(".html", StringComparison.OrdinalIgnoreCase));
        if (entry is null) return null;

        var outPath = Path.Combine(Path.GetTempPath(), $"WW-Smoke-Report-{env}-{id}.html");
        entry.ExtractToFile(outPath, overwrite: true);
        var html = await File.ReadAllTextAsync(outPath);
        return new ReportFile(html, outPath);
    }

    private static string? Extract(string json, string prop)
    {
        try { using var d = JsonDocument.Parse(json); return d.RootElement.TryGetProperty(prop, out var v) ? v.GetString() : null; }
        catch { return null; }
    }
}
