#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/deploy_sql.sh <sql-file> [environment]

Environment variables:
  SIMULATE_DEPLOY      Defaults to true. When true, no database connection is attempted.
  GCP_PROJECT_ID       Placeholder GCP project identifier.
  GCP_REGION           Placeholder GCP region.
  GCP_DB_TARGET        Placeholder database target name.
  DEPLOY_OUTPUT_DIR    Defaults to build/deploy.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

sql_file="$1"
environment="${2:-dev}"
simulate_deploy="${SIMULATE_DEPLOY:-true}"
gcp_project_id="${GCP_PROJECT_ID:-demo-project}"
gcp_region="${GCP_REGION:-us-central1}"
gcp_db_target="${GCP_DB_TARGET:-oracle-on-gce-demo}"
deploy_output_dir="${DEPLOY_OUTPUT_DIR:-build/deploy}"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

if [[ ! -f "$sql_file" ]]; then
  echo "SQL file not found: $sql_file" >&2
  exit 1
fi

if [[ "${sql_file##*.}" != "sql" ]]; then
  echo "Expected a .sql file, got: $sql_file" >&2
  exit 1
fi

if [[ ! -s "$sql_file" ]]; then
  echo "SQL file is empty: $sql_file" >&2
  exit 1
fi

mkdir -p "$deploy_output_dir"

artifact_base="$(basename "$sql_file" .sql)-${environment}"
payload_file="$deploy_output_dir/${artifact_base}.sql"
manifest_file="$deploy_output_dir/${artifact_base}.manifest"

cp "$sql_file" "$payload_file"

cat > "$manifest_file" <<EOF
timestamp=$timestamp
environment=$environment
simulate_deploy=$simulate_deploy
gcp_project_id=$gcp_project_id
gcp_region=$gcp_region
gcp_db_target=$gcp_db_target
sql_file=$sql_file
payload_file=$payload_file
EOF

echo "Prepared deployment payload: $payload_file"
echo "Prepared deployment manifest: $manifest_file"

if [[ "$simulate_deploy" == "true" ]]; then
  echo "Simulation mode enabled. No database changes were applied."
  echo "Simulated target: project=$gcp_project_id region=$gcp_region db=$gcp_db_target env=$environment"
  exit 0
fi

echo "Real deployment mode is not configured yet." >&2
echo "Install a PL/SQL client such as SQLcl or sqlplus and replace this block with your execution command." >&2
exit 1