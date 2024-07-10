#!/usr/bin/env sh

FABASOAD_LOG_CONFIG_DATE_FORMAT_DEFAULT="%Y-%m-%d %T"
FABASOAD_LOG_CONFIG_HEADER_DEFAULT="fabasoad-log"
FABASOAD_LOG_CONFIG_TEXT_COLOR_DEFAULT="true"
FABASOAD_LOG_CONFIG_TEXT_FORMAT_DEFAULT="[<header>] <time> level=<level> <message>"

_fabasoad_echo_text_color() {
  log_line="$1"
  level="$2"
  if [ "${FABASOAD_LOG_CONFIG_TEXT_COLOR:-${FABASOAD_LOG_CONFIG_TEXT_COLOR_DEFAULT}}" = "true" ]; then
    if [ "${level}" = "error" ]; then
      echo "\033[91m${log_line}\033[0m"
    elif [ "${level}" = "warning" ]; then
      echo "\033[93m${log_line}\033[0m"
    elif [  "${level}" = "info"  ]; then
      echo "${log_line}"
    else
      echo "\033[90m${log_line}\033[0m"
    fi
  else
    echo "${log_line}"
  fi
}

_fabasoad_text_bold() {
  if [ "${FABASOAD_LOG_CONFIG_TEXT_COLOR:-${FABASOAD_LOG_CONFIG_TEXT_COLOR_DEFAULT}}" = "true" ]; then
    echo "\033[1m$1\033[22m"
  else
    echo "$1"
  fi
}

_fabasoad_log_text() {
  level="$1"
  message="$2"

  log_line="${FABASOAD_LOG_CONFIG_TEXT_FORMAT:-${FABASOAD_LOG_CONFIG_TEXT_FORMAT_DEFAULT}}"
  log_line=${log_line/<header>/${FABASOAD_LOG_CONFIG_HEADER:-${FABASOAD_LOG_CONFIG_HEADER_DEFAULT}}}
  log_line=${log_line/<time>/$(date +"${FABASOAD_LOG_CONFIG_DATE_FORMAT:-${FABASOAD_LOG_CONFIG_DATE_FORMAT_DEFAULT}}")}
  log_line=${log_line/<level>/$(_fabasoad_text_bold "${level}")}
  log_line=${log_line/<message>/${message}}

  _fabasoad_echo_text_color "${log_line}" "${level}" >&2
}

_fabasoad_log_json() {
  level="$1"
  message="$2"

  json_msg="{"
  json_msg="${json_msg}\"timestamp\":\"$(date +"${FABASOAD_LOG_CONFIG_DATE_FORMAT:-${FABASOAD_LOG_CONFIG_DATE_FORMAT_DEFAULT}}")\","
  json_msg="${json_msg}\"header\":\"${FABASOAD_LOG_CONFIG_HEADER:-${FABASOAD_LOG_CONFIG_HEADER_DEFAULT}}\","
  json_msg="${json_msg}\"level\":\"${level}\","
  json_msg="${json_msg}\"message\":\"${message}\""
  json_msg="${json_msg}}"

  echo "${json_msg}" >&2
}

_fabasoad_log_xml() {
  level="$1"
  message="$2"

  xml_msg="<log>"
  xml_msg="${xml_msg}<timestamp>$(date +"${FABASOAD_LOG_CONFIG_DATE_FORMAT:-${FABASOAD_LOG_CONFIG_DATE_FORMAT_DEFAULT}}")</timestamp>"
  xml_msg="${xml_msg}<header>${FABASOAD_LOG_CONFIG_HEADER:-${FABASOAD_LOG_CONFIG_HEADER_DEFAULT}}</header>"
  xml_msg="${xml_msg}<level>${level}</level>"
  xml_msg="${xml_msg}<message>${message}</message>"
  xml_msg="${xml_msg}</log>"

  echo "${xml_msg}" >&2
}

fabasoad_log() {
  level="$1"
  message="$2"
  config_path="$3"

  if [ -f "${config_path}" ]; then
    log_init_lib="$(dirname $(realpath "${0}"))/fabasoad-log-init.sh"
    if [ -f "${log_init_lib}" ]; then
      . "${log_init_lib}"
      fabasoad_log_init "${config_path}"
    fi
  fi

  if [ "${FABASOAD_LOG_CONFIG_OUTPUT_FORMAT}" = "xml" ]; then
    _fabasoad_log_xml "${level}" "${message}"
  elif [ "${FABASOAD_LOG_CONFIG_OUTPUT_FORMAT}" = "json" ]; then
    _fabasoad_log_json "${level}" "${message}"
  else
    _fabasoad_log_text "${level}" "${message}"
  fi
}

# export
if [ ${BASH_SOURCE[0]} != $0 ]; then
  export -f fabasoad_log
else
  fabasoad_log "${@}"
  exit $?
fi
