#!/usr/bin/env sh

SCRIPTS_DIR=$(dirname $(realpath "$0"))
ROOT_DIR=$(dirname "${SCRIPTS_DIR}")

. "${SCRIPTS_DIR}/defaults.sh"

mkdir -p "${target_bin}"
for cmd in ${cmds}; do
  cp "${ROOT_DIR}/lib/${cmd}.sh" "${target_bin}/${bin}-${cmd}"
done
