# WW Smoke Tests — Launcher page

A zero-secret, static self-service page so any tester can kick off the WW Smoke
pipeline. The tester picks an **environment**, **browser**, and **legs at once**,
and the page hands them off to the pipeline's **own Run dialog in Azure DevOps**,
where they sign in with their normal ADO account. No PAT, no backend, no
credentials live in the page.

> Prefer a CLI that also **emails results**? See `runner/` (`wwsmoke`) — it
> queues the run, waits, and emails the report.

## Files
- `index.html` — the launcher (self-contained: HTML + CSS + JS, no dependencies).
- `staticwebapp.config.json` — Azure Static Web Apps routing/caching.

## One-time setup
Already wired for this pipeline. If you ever move it, set the values near the top
of `index.html`:

```js
const CONFIG = {
  org:     "EnterpriseRepo",
  project: "Application Services",
  PIPELINE_DEFINITION_ID: "697",   // Pipelines → WW Smoke Tests → ?definitionId=
};
```

The `ENVS` list mirrors the pipeline's `testEnv` parameter values — keep them in
sync if you add/rename an environment.

## Deploy to Azure Static Web Apps
**Portal:** Create a Static Web App → source = this repo → **App location** =
`/launcher` → **Api location** = blank → **Output location** = blank. SWA builds
on push and gives you a `https://<name>.azurestaticwebapps.net` URL.

**CLI:**
```bash
npx @azure/static-web-apps-cli deploy ./launcher \
  --deployment-token <SWA_DEPLOYMENT_TOKEN>
```

Restrict access (so only testers/staff see it) via the Static Web App's
**Authentication** settings (e.g. Microsoft Entra ID), since the page itself is
public HTML.

## How a tester uses it
1. Open the page, pick **environment / browser / legs at once**.
2. Click **Open the Run dialog in Azure DevOps** (new tab, ADO sign-in).
3. In ADO: **Run pipeline** → set the three shown values → **Run**.
4. **Non-prod:** results in the run's **Tests** tab + the `WW-Smoke-Report-<ENV>`
   artifact. **PROD:** the `WW-Smoke-Report-PROD` artifact (no Tests tab), with
   live progress in the *Run Smoke tests* step.

> Notes:
> - ADO does not support pre-filling pipeline parameters from a URL, so the page
>   shows the exact values to select rather than auto-filling them.
> - Selecting **PROD** locks *legs at once* to 1 (PROD runs as a single leg on
>   one agent, ~40 min). Register more `Production SQA Agents` to parallelize.
