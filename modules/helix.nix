{ config, lib, pkgs, ... }: with lib; imports [

(systemConfiguration {
  environment = {
    variables.EDITOR = "hx";
    shellAliases.x = "hx";
  };
})

(homeConfiguration {
  programs.nushell.configFile.text = mkAfter ''
    def --wrapped hx [...arguments] {
      if $env.TERM == "xterm-kitty" {
        kitty @ set-spacing padding=0
      }

      ^hx ...$arguments

      if $env.TERM == "xterm-kitty" {
        kitty @ set-spacing padding=${toString config.theme.padding}
      }
    }
  '';

  programs.helix = enabled {
    languages.language = let
      denoFormatter = language: {
        command = "deno";
        args    = [ "fmt" "-" "--ext" language ];
      };

      denoFormatterLanguages = map (name: {
        inherit name;

        auto-format = true;
        formatter   = denoFormatter name;
      }) [ "markdown" "json" ];

      prettier = language: {
        command = "prettier";
        args    = [ "--parser" language ];
      };

      prettierLanguages = map (name: {
        inherit name;

        auto-format = true;
        formatter   = prettier name;
      }) [ "css" "scss" "yaml" ];
    in denoFormatterLanguages ++ prettierLanguages ++ [
      {
        name              = "nix";
        auto-format       = false;
        formatter.command = "alejandra";
      }
      {
        name            = "cull";
        injection-regex = "cull";
        scope           = "scope.cull";

        comment-token    = "#";
        indent.unit      = "\t";
        indent.tab-width = 4;

        file-types = [ "cull" ];
        roots      = [ "build.cull" ];

        grammar = "python";
      }
      {
        name        = "html";
        # Added vto.
        file-types  = [ "asp" "aspx" "htm" "html" "jshtm" "jsp" "rhtml" "shtml" "volt" "vto" "xht" "xhtml" ];
        auto-format = false;
        formatter   = prettier "html";
      }
      {
        name             = "javascript";
        auto-format      = true;
        formatter        = denoFormatter "js";
        language-servers = [ "deno" ];
      }
      {
        name             = "jsx";
        auto-format      = true;
        formatter        = denoFormatter "jsx";
        language-servers = [ "deno" ];
      }
      {
        name             = "typescript";
        auto-format      = true;
        formatter        = denoFormatter "ts";
        language-servers = [ "deno" ];
      }
      {
        name             = "tsx";
        auto-format      = true;
        formatter        = denoFormatter "tsx";
        language-servers = [ "deno" ];
      }
    ];

    languages.language-server = {
      deno = {
        command = "deno";
        args    = [ "lsp" ];

        environment.NO_COLOR = "1";

        config.deno = enabled {
          lint     = true;
          unstable = true;

          suggest.imports.hosts."https://deno.land" = true;

          inlayHints = {
            enumMemberValues.enabled         = true;
            functionLikeReturnTypes.enabled  = true;
            parameterNames.enabled           = "all";
            parameterTypes.enabled           = true;
            propertyDeclarationTypes.enabled = true;
            variableTypes.enabled            = true;
          };
        };
      };

      rust-analyzer.config.check.command = "clippy";
    };

    settings.theme = "gruvbox_dark_hard";

    settings.editor = {
      color-modes            = true;
      completion-replace     = true;
      completion-trigger-len = 0;
      cursor-shape.insert    = "bar";
      cursorline             = true;
      bufferline             = "multiple";
      file-picker.hidden     = false;
      idle-timeout           = 0;
      line-number            = "relative";
      shell                  = [ "bash" "-c" ];
      text-width             = 100;
    };

    settings.editor.indent-guides = {
      character = "▏";
      render = true;
    };

    settings.editor.statusline.mode = {
      insert = "INSERT";
      normal = "NORMAL";
      select = "SELECT";
    };

    settings.editor.whitespace = {
      characters.tab = "→";
      render.tab     = "all";
    };

    settings.keys = genAttrs [ "normal" "select" ] (_: {
      D = "extend_to_line_end";
    });
  };
})

(desktopSystemPackages (with pkgs; [
  # CMAKE
  cmake-language-server

  # GO
  gopls

  # HTML
  vscode-langservers-extracted
  nodePackages_latest.prettier

  # KOTLIN
  # kotlin-language-server

  # LATEX
  texlab

  # LUA
  lua-language-server

  # MARKDOWN
  marksman

  # NIX
  alejandra
  nil

  # PYTHON
  python311Packages.python-lsp-server

  # RUST
  rust-analyzer-nightly

  # TYPESCRIPT & OTHERS
  deno

  # YAML
  yaml-language-server

  # ZIG
  zls
]))

]
