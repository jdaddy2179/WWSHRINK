namespace WWSmokeRunner;

// Command-line options, with interactive prompts for the important ones when
// they're not supplied as flags.
internal sealed class Options
{
    public string Environment { get; private set; } = "";
    public string Browser { get; private set; } = "";
    public int MaxParallel { get; private set; }
    public string To { get; private set; } = "";
    public bool NoEmail { get; private set; }
    public bool NoWait { get; private set; }
    public int TimeoutMinutes { get; private set; } = 90;

    public static Options Parse(string[] args, Config cfg)
    {
        var o = new Options
        {
            Environment = Get(args, "--env") ?? "",
            Browser = Get(args, "--browser") ?? "",
            To = Get(args, "--to") ?? "",
            NoEmail = args.Contains("--no-email"),
            NoWait = args.Contains("--no-wait"),
        };

        var parallel = Get(args, "--parallel");
        var timeout = Get(args, "--timeout");

        // Interactive fallback for env/browser when not passed.
        if (string.IsNullOrWhiteSpace(o.Environment))
            o.Environment = Choose("Environment", cfg.Environments, cfg.DefaultEnvironment);
        if (string.IsNullOrWhiteSpace(o.Browser))
            o.Browser = Choose("Browser", cfg.Browsers, cfg.DefaultBrowser);

        // PROD always runs as a single leg on one agent - force parallel 1.
        o.MaxParallel = string.Equals(o.Environment, "PROD", StringComparison.OrdinalIgnoreCase)
            ? 1
            : (int.TryParse(parallel, out var p) && p > 0 ? p : cfg.DefaultMaxParallel);

        if (int.TryParse(timeout, out var t) && t > 0) o.TimeoutMinutes = t;

        return o;
    }

    private static string? Get(string[] args, string name)
    {
        var i = Array.IndexOf(args, name);
        return i >= 0 && i + 1 < args.Length ? args[i + 1] : null;
    }

    private static string Choose(string label, string[] options, string dflt)
    {
        if (options.Length == 0) return dflt;
        Console.WriteLine($"{label}:");
        for (var i = 0; i < options.Length; i++)
            Console.WriteLine($"  {i + 1,2}) {options[i]}{(options[i] == dflt ? "  (default)" : "")}");
        Console.Write($"Pick 1-{options.Length} [{dflt}]: ");
        var line = Console.ReadLine();
        if (string.IsNullOrWhiteSpace(line)) return dflt;
        if (int.TryParse(line.Trim(), out var n) && n >= 1 && n <= options.Length) return options[n - 1];
        // Allow typing the value directly too.
        var match = options.FirstOrDefault(x => string.Equals(x, line.Trim(), StringComparison.OrdinalIgnoreCase));
        return match ?? dflt;
    }
}
