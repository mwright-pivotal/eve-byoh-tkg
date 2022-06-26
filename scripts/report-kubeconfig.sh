#!/bin/sh

# --- helper functions for logs ---
info()
{
    echo 'report-kubeconfig.sh-[INFO] ' "$@"
}
warn()
{
    echo 'report-kubeconfig.sh-[WARN] ' "$@" >&2
}
fatal()
{
    echo 'report-kubeconfig.sh-[ERROR] ' "$@" >&2
    exit 1
}

kubeconfig_path="$HOME/eve-kubeconfig.json"

if [ -n "${REPORT_URL}" ]; then
  info "Generating kubeconfig at $kubeconfig_path"
  sudo /home/pocuser/generate-kubeconfig.sh "$kubeconfig_path" || fatal "Failed to generate kubeconfig"

  info "Publishing kubeconfig report to $REPORT_URL"
  sudo curl -H "Content-Type: application/json" -X POST -d "$(sudo cat "$kubeconfig_path")" "$REPORT_URL"
else
  fatal "REPORT_URL variable is not passed. Not reporting the kubeconfig"
fi
