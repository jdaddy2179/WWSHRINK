using System.Text.RegularExpressions;

namespace WWSmokeRunner;

// Pulls the headline numbers out of the consolidated HTML report so we can put
// them in the email subject/body. Falls back to the build result if the report
// artifact isn't available.
internal sealed class ReportSummary
{
    public required string Environment { get; init; }
    public required string Verdict { get; init; }   // PASS / FAIL / NO RESULTS / <build result>
    public string PassRate { get; init; } = "";      // e.g. "98.2%"
    public string Counts { get; init; } = "";        // e.g. "168 of 171 tests"
    public bool HasReport { get; init; }

    public string Line =>
        HasReport
            ? $"Result: {Verdict} — {PassRate} passed ({Counts})."
            : $"Result: {Verdict} (no consolidated report artifact was found).";

    public string Subject => $"WW Smoke {Environment}: {Verdict}" + (HasReport ? $" — {PassRate}" : "");

    public static ReportSummary From(string? html, string? buildResult, string env)
    {
        if (string.IsNullOrWhiteSpace(html))
        {
            return new ReportSummary
            {
                Environment = env,
                Verdict = (buildResult ?? "unknown").ToUpperInvariant(),
                HasReport = false,
            };
        }

        var verdict = Match(html, @"class=['""]verdict['""][^>]*>([^<]+)<") ?? (buildResult ?? "unknown").ToUpperInvariant();
        var pct = Match(html, @"([\d.]+%)\s*passed");
        var counts = Match(html, @"(\d+)\s+of\s+(\d+)\s+tests", groups => $"{groups[1].Value} of {groups[2].Value} tests");

        return new ReportSummary
        {
            Environment = env,
            Verdict = verdict.Trim(),
            PassRate = pct ?? "",
            Counts = counts ?? "",
            HasReport = true,
        };
    }

    private static string? Match(string s, string pattern, Func<GroupCollection, string>? project = null)
    {
        var m = Regex.Match(s, pattern, RegexOptions.IgnoreCase);
        if (!m.Success) return null;
        return project is null ? m.Groups[1].Value : project(m.Groups);
    }
}
