# Group API BCBSM — Postman Smoke Test

Postman collection reconstructed from the Postman CLI run report (smoke test
of the WW Benefits Group API for BCBSM). The run executes one folder,
**Group API BCBSM Smoke Test**, with 6 requests and 135 assertions, against
multiple environments.

## Files

| File | Purpose |
| --- | --- |
| `Group_API_BCBSM_JJE.postman_collection.json` | The collection (6 requests + tests) |
| `env.ds11.postman_environment.json` | `baseUrl = http://ds11wwapi.dqdev.ad` |
| `env.ts06.postman_environment.json` | `baseUrl = http://waww2dws05t.dqtest.ad` |
| `env.ds10.postman_environment.json` | `baseUrl = http://waww2dws02d.dqdev.ad` |
| `env.qar.postman_environment.json`  | `baseUrl = http://WAWW2API56T.DQTEST.AD` |
| `env.tshf.postman_environment.json` | `baseUrl = http://WAWW2DWS14T.DQTEST.AD` |

## Requests

1. **Add Plan** — `POST {{baseUrl}}/v1/Benefits/Plan` (creates Client, Group, Plan)
2. **Modify Plan** — `PUT {{baseUrl}}/v1/Benefits/Plan`
3. **Same Plan** — `GET {{baseUrl}}/v1/Benefits/Plan/BusinessUnit/BCBSM/ExternalId/{{extSubGroupId}}/PlanName/{{modifiedPlanName}}/AllDetails`
4. **Terminate Plan** — `POST {{baseUrl}}/v1/Benefits/Plan/Terminate`
5. **BCN Small Group** — `POST {{baseUrl}}/v1/Benefits/Plan`
6. **BCN Large Group** — `POST {{baseUrl}}/v1/Benefits/Plan`

## Running

### Postman CLI
```bash
postman collection run Group_API_BCBSM_JJE.postman_collection.json \
  -e env.ds11.postman_environment.json \
  -r html --reporter-html-export ds11-test-results.html
```

### Newman
```bash
newman run Group_API_BCBSM_JJE.postman_collection.json \
  -e env.ds11.postman_environment.json \
  -r cli,html
```

## Notes

- The collection uses a `{{baseUrl}}` variable so the same collection runs
  against every environment; pick the server by selecting the matching
  environment file.
- Request bodies are minimal placeholders. The CLI run in the source report
  used the collection's own saved bodies / pre-request data generation
  (e.g. dated `ExternalId` / `PlanName` values such as
  `DoNotUseSmokeTestExtSubGroupId<yyyymmdd>NNN`). Replace the placeholder
  bodies and variable values with the real smoke-test payloads if you have
  the original export.
- Test scripts assert what the report logged: HTTP 200, the
  `RecordId` / `ResultCode` / `Message` result rows, and the full node-name
  structure validated by the **Same Plan** request.
