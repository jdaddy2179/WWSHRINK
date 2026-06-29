# WW Smoke Tests — Launcher page

A zero-secret, static self-service page so any tester can kick off the WW Smoke
pipeline. The tester picks a **business unit** + **environment**, and the page
hands them off to the pipeline's **own Run dialog in Azure DevOps**, where they
sign in with their normal ADO account. No PAT, no backend, no credentials live
in the page.

## Files
- `index.html` — the launcher (self-contained: HTML + CSS + JS, no dependencies).
- `staticwebapp.config.json` — Azure Static Web Apps routing/caching.

## One-time setup
Open `index.html` and set **one** value near the top:

```js
const CONFIG = {
  ...
  PIPELINE_DEFINITION_ID: "REPLACE_ME",   // ← your pipeline id
};
```

Find the id in Azure DevOps: **Pipelines → WW Smoke Tests** → the number after
`?definitionId=` in the browser URL. Until it's set, the page still works but the
button opens the Pipelines list instead of the specific pipeline.

The business-unit → suite-id map in `index.html` (`BUS`) mirrors the
`testSuite` parameter in `azure-pipelines.yml`. If you add/rename a BU suite,
update both.

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
1. Open the page, click a **business unit**, set **environment / browser /
   agents / Allure**.
2. Click **Open Run dialog in Azure DevOps** (new tab, ADO sign-in).
3. In ADO: **Run pipeline** → set the shown parameter values → **Run**.
4. Results land in the run's **Tests** tab and in **Test Plans**.

> Note: ADO does not support pre-filling pipeline parameters from a URL, so the
> page shows the exact values to select rather than auto-filling them.
