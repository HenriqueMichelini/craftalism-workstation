#!/usr/bin/env bash

WORKSTATION_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case ":${PATH}:" in
  *":${WORKSTATION_ROOT}/bin:"*) ;;
  *) export PATH="${WORKSTATION_ROOT}/bin:${PATH}" ;;
esac

export CRAFTALISM_WORKSTATION_ROOT="${WORKSTATION_ROOT}"
export WORKSTATION_STATE_DIR="${WORKSTATION_STATE_DIR:-${HOME}/.workstation/state}"
