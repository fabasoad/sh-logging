#!/usr/bin/env sh

SCRIPTS_DIR=$(dirname $(realpath "$0"))
ROOT_DIR=$(dirname "${SCRIPTS_DIR}")

. "${SCRIPTS_DIR}/defaults.sh"

for cmd in ${cmds}; do
  rm -f "${target_bin}/${bin}-${cmd}"
done
