using System.Net;
using System.Net.Mail;

namespace WWSmokeRunner;

// Sends the results email via SMTP. Attaches the full HTML report when we have
// it, and puts a short summary + the run link in the body. SMTP password (only
// if the relay requires auth) comes from WWSMOKE_SMTP_PASSWORD.
internal static class Email
{
    public static void Send(Config cfg, string to, ReportSummary summary, string runUrl, string? reportHtml, string? reportPath)
    {
        if (string.IsNullOrWhiteSpace(cfg.SmtpHost))
            throw new InvalidOperationException("Email.SmtpHost is not set in appsettings.json.");
        if (string.IsNullOrWhiteSpace(cfg.EmailFrom))
            throw new InvalidOperationException("Email.From is not set in appsettings.json.");
        if (string.IsNullOrWhiteSpace(to))
            throw new InvalidOperationException("No recipient (set Email.DefaultTo in appsettings.json or pass --to).");

        var body =
            "<div style=\"font:14px Segoe UI,Arial\">" +
            $"<h2 style=\"margin:0 0 8px\">WW Smoke — {Html(summary.Environment)}</h2>" +
            $"<p style=\"font-size:16px\"><b>{Html(summary.Verdict)}</b>" +
            (summary.HasReport ? $" &middot; {Html(summary.PassRate)} passed &middot; {Html(summary.Counts)}" : "") +
            "</p>" +
            $"<p><a href=\"{Html(runUrl)}\">Open the run in Azure DevOps</a></p>" +
            (summary.HasReport
                ? "<p>The full consolidated report is attached (<code>WW-Smoke-Report.html</code>).</p>"
                : "<p>No consolidated report artifact was found for this run.</p>") +
            "<hr><p style=\"color:#888;font-size:12px\">Sent by the WW Smoke runner.</p>" +
            "</div>";

        using var msg = new MailMessage { From = new MailAddress(cfg.EmailFrom), Subject = summary.Subject, IsBodyHtml = true, Body = body };
        foreach (var addr in to.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            msg.To.Add(addr);

        if (!string.IsNullOrWhiteSpace(reportPath) && File.Exists(reportPath))
            msg.Attachments.Add(new Attachment(reportPath) { Name = "WW-Smoke-Report.html" });

        using var smtp = new SmtpClient(cfg.SmtpHost, cfg.SmtpPort) { EnableSsl = cfg.SmtpUseSsl };
        var pwd = Environment.GetEnvironmentVariable("WWSMOKE_SMTP_PASSWORD");
        if (!string.IsNullOrWhiteSpace(pwd))
            smtp.Credentials = new NetworkCredential(cfg.EmailFrom, pwd);
        else
            smtp.UseDefaultCredentials = true; // domain-authenticated relay (no password needed)

        smtp.Send(msg);
    }

    private static string Html(string? s) =>
        (s ?? "").Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;");
}
