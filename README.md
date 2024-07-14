# Shell logging

[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://stand-with-ukraine.pp.ua)
![GitHub release](https://img.shields.io/github/v/release/fabasoad/sh-logging?include_prereleases)
![security](https://github.com/fabasoad/sh-logging/actions/workflows/security.yml/badge.svg)
![linting](https://github.com/fabasoad/sh-logging/actions/workflows/linting.yml/badge.svg)

Shell library for logging.

## Table of Contents

- [Installation](#installation)
- [Supported parameters](#supported-parameters)
  - [Log level](#log-level)
  - [Output format](#output-format)
  - [Date format](#date-format)
  - [Header](#header)
  - [Text color](#text-color)
  - [Text format](#text-format)

## Installation

```shell
bpkg install fabasoad/sh-logging
```

More information on installation options you can find [here](https://github.com/bpkg/bpkg?tab=readme-ov-file#installing-packages).

## Supported parameters

### Log level

Level of logging to produce.

- Environment variable: `FABASOAD_LOG_CONFIG_LOG_LEVEL`.
- Possible options: `debug`, `info`, `warning`, `error`, `off`.
- Default value: `info`.

The rules are the following:

- If log level is `off` then no logs will be produced.
- If log level is `debug` then all logs will be produced.
- If log level is `info` then all logs except of `debug` logs will be produced.
- If log level is `warning` then only `warning` and `error` logs will be produced.
- If log level is `error` then only `error` logs will be produced.

### Output format

The format of logs to produce.

- Environment variable: `FABASOAD_LOG_CONFIG_OUTPUT_FORMAT`.
- Possible options: `text`, `json`, `xml`.
- Default value: `text`.

### Date format

Format that passes to [date](https://pubs.opengroup.org/onlinepubs/009695399/utilities/date.html)
shell command, e.g. if you want `date +%s` to be used then you need to use `%s`.

- Environment variable: `FABASOAD_LOG_CONFIG_DATE_FORMAT`.
- Possible options: Any `string` value.
- Default value: `%Y-%m-%d %T`.

### Header

It is usually used to mention your program name in the logs. For example, if you
want your logs to be something like this:

```text
[my-app] [error] Validation error!
```

Then you need to use `my-app` as a header value.

- Environment variable: `FABASOAD_LOG_CONFIG_HEADER`.
- Possible options: Any `string` value.
- Default value: `fabasoad-log`.

### Text color

Enables/disables coloring of the logs output.

- Environment variable: `FABASOAD_LOG_CONFIG_TEXT_COLOR`.
- Possible options: `true`, `false`.
- Default value: `true`.

### Text format

The format/pattern of the text logs. It works only if output format is set to `text`.

- Environment variable: `FABASOAD_LOG_CONFIG_TEXT_FORMAT`.
- Possible options: Any `string` value.
- Default value: `[<header>] <time> level=<level> <message>`.

It supports the following templates: `<header>`, `<time>`, `<level>`, `<message>`.
For example, if you want your logs to be like this:

```text
[my-app] [info] "2024-07-14 21:30:47" Downloading binary
```

Then you need to set text format to `[<header>] [<level>] "<time>" <message>`.
