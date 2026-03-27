#!/usr/bin/env bash
# Run the certificate generator.
# Usage:  ./bin/run-s-certificate.sh <domain> [options]
#
# When run from within the xC-mcn-demo project, automatically detects
# and uses the project config (setup-init/config.yaml) for CA paths
# and output directory. Override with --project-config or -p.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Auto-activate the virtual environment if it exists and isn't already active.
if [ -z "${VIRTUAL_ENV:-}" ]; then
    if [ -f "venv/bin/activate" ]; then
        # shellcheck disable=SC1091
        source venv/bin/activate
    elif [ -f ".venv/bin/activate" ]; then
        # shellcheck disable=SC1091
        source .venv/bin/activate
    fi
fi

# Auto-detect project config if not explicitly provided
PROJECT_CONFIG_ARGS=""
if [[ ! " $* " =~ " --project-config " ]] && [[ ! " $* " =~ " -p " ]]; then
    REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
    if [ -n "$REPO_ROOT" ] && [ -f "${REPO_ROOT}/setup-init/config.yaml" ]; then
        PROJECT_CONFIG_ARGS="--project-config ${REPO_ROOT}/setup-init/config.yaml"
    fi
fi

# shellcheck disable=SC2086
PYTHONPATH=src exec python3 -m s_certificate $PROJECT_CONFIG_ARGS "$@"
