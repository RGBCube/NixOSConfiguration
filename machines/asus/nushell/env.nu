let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |string|
      $string
      | split row (char esep)
      | path expand -n
    }
    to_string: { |value|
      $value
      | path expand -n
      | str join (char esep)
    }
  }
}

let-env NU_LIB_DIRS = [
    ($nu.config-path
     | path dirname
     | path join 'scripts')
]

let-env NU_PLUGIN_DIRS = [
    ($nu.config-path
     | path dirname
     | path join 'plugins')
]

let-env STARSHIP_SHELL = "nu"
let-env STARSHIP_SESSION_KEY = (random chars -l 16)

let-env PROMPT_INDICATOR = ""
let-env PROMPT_MULTILINE_INDICATOR = (^/run/current-system/sw/bin/starship prompt --continuation)

let-env PROMPT_COMMAND = { ||
    let width = term size | get columns
    ^/run/current-system/sw/bin/starship prompt $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
}

let-env PROMPT_COMMAND_RIGHT = { ||
    let width = term size | get columns
    ^/run/current-system/sw/bin/starship prompt --right $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
}