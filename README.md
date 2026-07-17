# plsqllab

This repository includes a simulated PL/SQL deployment pipeline for a future GCP-hosted database target.

## What it does

- Validates that a `.sql` file exists and is not empty.
- Packages the SQL file into `build/deploy/`.
- Writes a deployment manifest with environment and GCP target placeholders.
- Simulates deployment by default, because no database is configured yet.

## Files

- `scripts/deploy_sql.sh`: local deploy script used by CI.
- `cloudbuild.yaml`: GCP Cloud Build pipeline for simulated deployment.
- `.github/workflows/simulate-plsql-deploy.yml`: GitHub Actions workflow for the same simulated flow.

## Local run

```bash
chmod +x scripts/deploy_sql.sh
scripts/deploy_sql.sh test.sql dev
```

Optional environment variables:

```bash
export SIMULATE_DEPLOY=true
export GCP_PROJECT_ID=my-gcp-project
export GCP_REGION=us-central1
export GCP_DB_TARGET=oracle-on-gce-demo
```

## Run in Cloud Build

```bash
gcloud builds submit --config cloudbuild.yaml \
	--substitutions _SQL_FILE=test.sql,_ENVIRONMENT=dev,_SIMULATE_DEPLOY=true,_GCP_REGION=us-central1,_GCP_DB_TARGET=oracle-on-gce-demo
```

## Converting to a real deployment later

Replace the final block in `scripts/deploy_sql.sh` with a real PL/SQL client command such as SQLcl or `sqlplus`, then pass the database connection settings through Cloud Build substitutions or secrets.