namespace WWSmokeRunner;

// wwsmoke — kicks off the WW Smoke pipeline in Azure DevOps, waits for it to
// finish, downloads the consolidated report, and emails the results.
//
// Auth: set the PAT in the WWSMOKE_ADO_PAT environment variable (a PAT with
// Build: Read & Execute). SMTP password (if your relay needs one) goes in
// WWSMOKE_SMTP_PASSWORD. Nothing secret is stored in files.
internal static class Program
{
    private static async Task<int> Main(string[] args)
    {
        try
        {
            if (args.Contains("-h") || args.Contains("--help")) { PrintHelp(); return 0; }

            var cfg = Config.Load();
            var opt = Options.Parse(args, cfg);

            var pat = Environment.GetEnvironmentVariable("WWSMOKE_ADO_PAT");
            if (string.IsNullOrWhiteSpace(pat))
            {
                Console.Error.WriteLine("ERROR: set WWSMOKE_ADO_PAT to an Azure DevOps PAT (Build: Read & Execute).");
                return 2;
            }

            var ado = new AdoClient(cfg.Org, cfg.Project, pat);

            Console.WriteLine($"WW Smoke — queuing a run");
            Console.WriteLine($"  Environment : {opt.Environment}");
            Console.WriteLine($"  Browser     : {opt.Browser}");
            Console.WriteLine($"  Parallel    : {opt.MaxParallel}");
            Console.WriteLine();

            var build = await ado.QueueAsync(cfg.PipelineId, cfg.SourceBranch, opt.Environment, opt.Browser, opt.MaxParallel);
            Console.WriteLine($"Queued build {build.BuildNumber} (id {build.Id})");
            Console.WriteLine($"  {build.WebUrl}");

            if (opt.NoWait)
            {
                Console.WriteLine("\n--no-wait set; not waiting for completion or emailing.");
                return 0;
            }

            Console.WriteLine("\nWaiting for the run to finish (Ctrl-C to stop watching; the run keeps going)...");
            var final = await ado.WaitAsync(build.Id, TimeSpan.FromMinutes(opt.TimeoutMinutes),
                onTick: s => Console.Write($"\r  status: {s,-12}"));
            Console.WriteLine($"\r  status: {final.Status} → result: {final.Result}      ");

            // Download + parse the consolidated report for this environment.
            var report = await ado.TryDownloadReportAsync(build.Id, opt.Environment);
            var summary = ReportSummary.From(report?.Html, final.Result, opt.Environment);
            var passed = string.Equals(final.Result, "succeeded", StringComparison.OrdinalIgnoreCase);

            // Results, right in the console.
            Console.WriteLine();
            Console.WriteLine("==================== RESULTS ====================");
            var prev = Console.ForegroundColor;
            Console.ForegroundColor = passed ? ConsoleColor.Green : ConsoleColor.Red;
            Console.WriteLine($"  {opt.Environment}: {summary.Verdict}" + (summary.HasReport ? $"  ({summary.PassRate} passed, {summary.Counts})" : ""));
            Console.ForegroundColor = prev;
            Console.WriteLine($"  Run: {build.WebUrl}");
            if (summary.Failures.Count > 0)
            {
                Console.WriteLine($"  Failing tests ({summary.Failures.Count}):");
                foreach (var (bu, test) in summary.Failures.Take(50))
                    Console.WriteLine($"    - [{bu}] {test}");
            }
            if (report is not null)
                Console.WriteLine($"  Full report: {report.HtmlPath}");
            else
                Console.WriteLine($"  (No report artifact found — open the run for details.)");
            Console.WriteLine("=================================================");

            // Email is off by default (Email.Enabled=false in appsettings.json).
            // Flip it back on there to also email the report.
            if (cfg.EmailEnabled && !opt.NoEmail)
            {
                var to = string.IsNullOrWhiteSpace(opt.To) ? cfg.DefaultTo : opt.To;
                Email.Send(cfg, to, summary, build.WebUrl, report?.Html, report?.HtmlPath);
                Console.WriteLine($"Emailed results to {to}.");
            }

            // Exit code mirrors the build result so this is CI-friendly too.
            return passed ? 0 : 1;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"\nERROR: {ex.Message}");
            return 3;
        }
    }

    private static void PrintHelp()
    {
        Console.WriteLine(@"wwsmoke — run the WW Smoke tests and email the results.

Usage:
  wwsmoke [--env TS06] [--browser msedge] [--parallel 3] [--to a@b.com]
          [--no-email] [--no-wait] [--timeout 90]

Options:
  --env <ENV>        Target environment (e.g. TS06, DS10, PROD). Prompted if omitted.
  --browser <b>      msedge or chrome.
  --parallel <n>     Business-unit legs at once (PROD uses 1 regardless).
  --to <addr>        Email recipient(s), comma-separated. Defaults to appsettings.
  --no-email         Run and wait, but don't send email.
  --no-wait          Queue the run and exit (no wait, no email).
  --timeout <min>    Max minutes to wait for completion (default 90).
  -h, --help         Show this help.

Environment variables:
  WWSMOKE_ADO_PAT        Azure DevOps PAT (Build: Read & Execute). REQUIRED.
  WWSMOKE_SMTP_PASSWORD  SMTP password, only if your relay requires auth.

Config: appsettings.json (org, project, pipeline id, SMTP settings, defaults).");
    }
}
