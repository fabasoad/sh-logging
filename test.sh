#!/usr/bin/env sh

#. "./fabasoad-log-init"
#. "./fabasoad-log"

#export FABASOAD_LOG_CONFIG_OUTPUT_FORMAT="json"
./fabasoad-log-init ".fabasoad-logging.json"
./fabasoad-log "debug" "This is debug msg"
./fabasoad-log "info" "This is info msg"
./fabasoad-log "warning" "This is warning msg"
./fabasoad-log "error" "This is error msg"
