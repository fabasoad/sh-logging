#!/usr/bin/env bash

FABASOAD_LOG_CONFIG_OUTPUT_FORMAT_DEFAULT="text"
FABASOAD_LOG_CONFIG_DATE_FORMAT_DEFAULT="%Y-%m-%d %T"
FABASOAD_LOG_CONFIG_HEADER_DEFAULT="fabasoad-log"
FABASOAD_LOG_CONFIG_TEXT_COLOR_DEFAULT="true"
FABASOAD_LOG_CONFIG_TEXT_FORMAT_DEFAULT="[<header>] <time> level=<level> <message>"
FABASOAD_LOG_CONFIG_LOG_LEVEL_DEFAULT="info"

# Initialization

_fabasoad_log_init() {
  header="[fabasoad-log]"
  output_format="text"
  text_format="[<header>] <time> level=<level> <message>"
  date_format="%Y-%m-%d %T"
  text_color="true"
  log_level="info"

  config_path="${1}"

  if [ -f "${config_path}" ]; then
    header=$(jq -r --arg var1 "${header}" 'try .config.header catch $var1' "${config_path}")
    output_format_temp=$(jq -r --arg var1 "${output_format}" 'try .config["output-format"] catch $var1' "${config_path}")
    if [ "${output_format_temp}" = "json" ] || [ "${output_format_temp}" = "xml" ] || [ "${output_format_temp}" = "text" ]; then
      output_format="${output_format_temp}"
    fi
    text_format=$(jq -r --arg var1 "${text_format}" 'try .config["text-format"] catch $var1' "${config_path}")
    date_format=$(jq -r --arg var1 "${date_format}" 'try .config["date-format"] catch $var1' "${config_path}")
    text_color_temp=$(jq -r --arg var1 "${text_color}" 'try .config["text-color"] catch $var1' "${config_path}")
    if [ "${text_color_temp}" = "true" ] || [ "${text_color_temp}" = "false" ]; then
      text_color="${text_color_temp}"
    fi
    log_level_temp=$(jq -r --arg var1 "${log_level}" 'try .config["log-level"] catch $var1' "${config_path}")
    if [ "${log_level_temp}" = "error" ] \
      || [ "${log_level_temp}" = "warning" ] \
      || [ "${log_level_temp}" = "info" ] \
      || [ "${log_level_temp}" = "debug" ] \
      || [ "${log_level_temp}" = "off" ]; then
      log_level="${log_level_temp}"
    fi
  fi

  if [ -n "${header}" ]; then
    export FABASOAD_LOG_CONFIG_HEADER="${header}"
  fi

  if [ -n "${output_format}" ]; then
    export FABASOAD_LOG_CONFIG_OUTPUT_FORMAT="${output_format}"
  fi

  if [ -n "${text_format}" ]; then
    export FABASOAD_LOG_CONFIG_TEXT_FORMAT="${text_format}"
  fi

  if [ -n "${date_format}" ]; then
    export FABASOAD_LOG_CONFIG_DATE_FORMAT="${date_format}"
  fi

  if [ -n "${text_color}" ]; then
    export FABASOAD_LOG_CONFIG_TEXT_COLOR="${text_color}"
  fi

  if [ -n "${log_level}" ]; then
    export FABASOAD_LOG_CONFIG_LOG_LEVEL="${log_level}"
  fi
}

# Text modifications

_fabasoad_wrap_text_with_color() {
  log_line="${1}"
  level="${2}"
  if [ "${FABASOAD_LOG_CONFIG_TEXT_COLOR:-${FABASOAD_LOG_CONFIG_TEXT_COLOR_DEFAULT}}" = "true" ]; then
    if [ "${level}" = "error" ]; then
      printf "\033[91m${log_line}\033[0m"
    elif [ "${level}" = "warning" ]; then
      printf "\033[93m${log_line}\033[0m"
    elif [  "${level}" = "info"  ]; then
      printf "${log_line}"
    else
      printf "\033[90m${log_line}\033[0m"
    fi
  else
    printf "${log_line}"
  fi
}

_fabasoad_wrap_text_with_bold() {
  if [ "${FABASOAD_LOG_CONFIG_TEXT_COLOR:-${FABASOAD_LOG_CONFIG_TEXT_COLOR_DEFAULT}}" = "true" ]; then
    echo "\033[1m${1}\033[22m"
  else
    echo "${1}"
  fi
}

# Log level

_fabasoad_is_printing_error_ok() {
  log_level="${FABASOAD_LOG_CONFIG_LOG_LEVEL:-${FABASOAD_LOG_CONFIG_LOG_LEVEL_DEFAULT}}"
  if [ "${log_level}" != "off" ]; then
    echo "true"
  else
    echo "false"
  fi
}

_fabasoad_is_printing_warning_ok() {
  log_level="${FABASOAD_LOG_CONFIG_LOG_LEVEL:-${FABASOAD_LOG_CONFIG_LOG_LEVEL_DEFAULT}}"
  if [ "${log_level}" != "off" ] && [ "${log_level}" != "error" ]; then
    echo "true"
  else
    echo "false"
  fi
}

_fabasoad_is_printing_info_ok() {
  log_level="${FABASOAD_LOG_CONFIG_LOG_LEVEL:-${FABASOAD_LOG_CONFIG_LOG_LEVEL_DEFAULT}}"
  if [ "${log_level}" = "debug" ] || [ "${log_level}" = "info" ]; then
    echo "true"
  else
    echo "false"
  fi
}

_fabasoad_is_printing_debug_ok() {
  log_level="${FABASOAD_LOG_CONFIG_LOG_LEVEL:-${FABASOAD_LOG_CONFIG_LOG_LEVEL_DEFAULT}}"
  if [ "${log_level}" = "debug" ]; then
    echo "true"
  else
    echo "false"
  fi
}

# Printing

_fabasoad_print_log() {
  level="${1}"
  message="${2}"

  if [ "${level}" = "error" ] && [ "$(_fabasoad_is_printing_error_ok)" = "true" ]; then # error
    printf "${message}\n" >&2
  elif [ "${level}" = "warning" ] && [ "$(_fabasoad_is_printing_warning_ok)" = "true" ]; then # warning
    printf "${message}\n" >&2
  elif [ "${level}" = "info" ] && [ "$(_fabasoad_is_printing_info_ok)" = "true" ]; then # info
    printf "${message}\n" >&2
  elif [ "${level}" = "debug" ] && [ "$(_fabasoad_is_printing_debug_ok)" = "true" ]; then # debug
    printf "${message}\n" >&2
  fi
}

_fabasoad_log_text() {
  level="${1}"
  message="${2}"

  text_msg="${FABASOAD_LOG_CONFIG_TEXT_FORMAT:-${FABASOAD_LOG_CONFIG_TEXT_FORMAT_DEFAULT}}"
  text_msg=${text_msg/<header>/${FABASOAD_LOG_CONFIG_HEADER:-${FABASOAD_LOG_CONFIG_HEADER_DEFAULT}}}
  text_msg=${text_msg/<time>/$(date +"${FABASOAD_LOG_CONFIG_DATE_FORMAT:-${FABASOAD_LOG_CONFIG_DATE_FORMAT_DEFAULT}}")}
  text_msg=${text_msg/<level>/$(_fabasoad_wrap_text_with_bold "${level}")}
  text_msg=${text_msg/<message>/${message}}

  text_msg=$(_fabasoad_wrap_text_with_color "${text_msg}" "${level}")
  _fabasoad_print_log "${level}" "${text_msg}"
}

_fabasoad_log_json() {
  timestamp="$(date +"${FABASOAD_LOG_CONFIG_DATE_FORMAT:-${FABASOAD_LOG_CONFIG_DATE_FORMAT_DEFAULT}}")"
  header="${FABASOAD_LOG_CONFIG_HEADER:-${FABASOAD_LOG_CONFIG_HEADER_DEFAULT}}"

  json_msg=$(jq -cn \
    --arg timestamp "${timestamp}" \
    --arg header "${header}" \
    --arg level "${1}" \
    --arg message "${2}" \
    '{
      timestamp: $timestamp,
      header: $header,
      level: $level,
      message: $message
    }')

  _fabasoad_print_log "${level}" "${json_msg}"
}

_fabasoad_log_xml() {
  level="${1}"
  message="${2}"

  xml_msg="<log>"
  xml_msg="${xml_msg}<timestamp>$(date +"${FABASOAD_LOG_CONFIG_DATE_FORMAT:-${FABASOAD_LOG_CONFIG_DATE_FORMAT_DEFAULT}}")</timestamp>"
  xml_msg="${xml_msg}<header>${FABASOAD_LOG_CONFIG_HEADER:-${FABASOAD_LOG_CONFIG_HEADER_DEFAULT}}</header>"
  xml_msg="${xml_msg}<level>${level}</level>"
  xml_msg="${xml_msg}<message>${message}</message>"
  xml_msg="${xml_msg}</log>"

  _fabasoad_print_log "${level}" "${xml_msg}"
}

# Public functions

# Prints log line.
# Parameters:
# 1. (Required) Log level. Possible values: debug, info, warning, error, off.
# 2. (Required) Log message.
# 2. (Optional) Path to the config file.
#
# Usage example:
# fabasoad_log "error" "This is error message"
# fabasoad_log "debug" "This is debug message" "./config.json"
fabasoad_log() {
  level="${1}"
  message="${2}"
  config_path="${3:-""}"

  if [ -f "${config_path}" ]; then
    _fabasoad_log_init "${config_path}"
  fi

  case "${FABASOAD_LOG_CONFIG_OUTPUT_FORMAT:-${FABASOAD_LOG_CONFIG_OUTPUT_FORMAT_DEFAULT}}" in
    "xml")
      log_func="_fabasoad_log_xml"
      ;;
    "json")
      log_func="_fabasoad_log_json"
      ;;
    *)
      log_func="_fabasoad_log_text"
      ;;
  esac

  ${log_func} "${level}" "${message}"
}

# export
if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  export -f fabasoad_log
else
  fabasoad_log "${@}"
  exit $?
fi
