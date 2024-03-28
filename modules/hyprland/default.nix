{ ulib, pkgs, upkgs, theme, ... }: with ulib; merge3

(desktopSystemConfiguration {
  hardware.opengl = enabled {};

  xdg.portal = enabled {
    config.common.default = "*";

    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
    ];
  };
})

(desktopHomeConfiguration {
  wayland.windowManager.hyprland = with theme; enabled {
    package = upkgs.hyprland;

    extraConfig =
    ''
      monitor = , preferred, auto, 1
    ''
    +
    ''
      windowrule = noinitialfocus
    ''
    +
    ''
      exec-once = wl-paste --type text  --watch cliphist store -max-items 1000
      exec-once = wl-paste --type image --watch cliphist store -max-items 1000

      exec = pkill swaybg; swaybg --image ${./wallpaper.png}

      exec = pkill --signal SIGUSR2 waybar
    ''
    +
    ''
      binde = SUPER, left , movefocus, l
      binde = SUPER, down , movefocus, d
      binde = SUPER, up   , movefocus, u
      binde = SUPER, right, movefocus, r

      binde = SUPER, h, movefocus, l
      binde = SUPER, j, movefocus, d
      binde = SUPER, k, movefocus, u
      binde = SUPER, l, movefocus, r
    ''
    +
    ''
      bind = SUPER    , TAB, workspace, e+1
      bind = SUPER+ALT, TAB, workspace, e-1

      bind = SUPER, mouse_up,   workspace, e+1
      bind = SUPER, mouse_down, workspace, e-1

      bind = SUPER, 1, workspace, 1
      bind = SUPER, 2, workspace, 2
      bind = SUPER, 3, workspace, 3
      bind = SUPER, 4, workspace, 4
      bind = SUPER, 5, workspace, 5

      bind = SUPER+ALT, 1, movetoworkspacesilent, 1
      bind = SUPER+ALT, 2, movetoworkspacesilent, 2
      bind = SUPER+ALT, 3, movetoworkspacesilent, 3
      bind = SUPER+ALT, 4, movetoworkspacesilent, 4
      bind = SUPER+ALT, 5, movetoworkspacesilent, 5

      bindm = SUPER, mouse:272, movewindow
      bindm = SUPER, mouse:274, movewindow
    ''
    +
    ''
      binde = SUPER+CTRL, left , resizeactive, -100 0
      binde = SUPER+CTRL, down , resizeactive, 0 100
      binde = SUPER+CTRL, up   , resizeactive, 0 -100
      binde = SUPER+CTRL, right, resizeactive, 100 0

      binde = SUPER+CTRL, h, resizeactive, -100 0
      binde = SUPER+CTRL, j, resizeactive, 0 100
      binde = SUPER+CTRL, k, resizeactive, 0 -100
      binde = SUPER+CTRL, l, resizeactive, 100 0

      bindm = SUPER, mouse:273, resizewindow
    ''
    +
    ''
      bind = SUPER+ALT, left , movewindow, l
      bind = SUPER+ALT, down , movewindow, d
      bind = SUPER+ALT, up   , movewindow, u
      bind = SUPER+ALT, right, movewindow, r

      bind = SUPER+ALT, h, movewindow, l
      bind = SUPER+ALT, j, movewindow, d
      bind = SUPER+ALT, k, movewindow, u
      bind = SUPER+ALT, l, movewindow, r
    ''
    +
    ''
      bind = SUPER    , Q, killactive
      bind = SUPER    , F, fullscreen
      bind = SUPER+ALT, F, togglefloating

      bind = SUPER+ALT, RETURN, exec, kitty
      bind = SUPER    , RETURN, exec, ghostty --gtk-single-instance=true
      bind = SUPER    , W     , exec, firefox
      bind = SUPER    , D     , exec, discordcanary
      bind = SUPER    , E     , exec, fractal
      bind = SUPER    , M     , exec, thunderbird
      bind = SUPER    , T     , exec, thunar
      bind = SUPER    , C     , exec, hyprpicker --autocopy

      bind = SUPER, B, exec, pkill --signal SIGUSR1 waybar

      bind = SUPER, SPACE, exec, pkill fuzzel; fuzzel
      bind = SUPER, V    , exec, pkill fuzzel; cliphist list | fuzzel --dmenu | cliphist decode | wl-copy

      bind =    , PRINT, exec, pkill grim; grim -g "$(slurp -w 0)" - | swappy -f - -o - | wl-copy --type image/png
      bind = ALT, PRINT, exec, pkill grim; grim                    - | swappy -f - -o - | wl-copy --type image/png
    ''
    +
    ''
      bindle = , XF86AudioRaiseVolume, exec, wpctl set-volume --limit 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      bindle = , XF86AudioLowerVolume, exec, wpctl set-volume             @DEFAULT_AUDIO_SINK@ 5%-

      bindle = , XF86AudioMute   , exec, wpctl set-mute @DEFAULT_AUDIO_SINK@   toggle
      bindle = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      bindle = , XF86MonBrightnessUp  , exec, brightnessctl set               5%+
      bindle = , XF86MonBrightnessDown, exec, brightnessctl set --min-value=0 5%-

      bindl = , XF86PowerOff, exec, pkill fuzzel; echo -en "Suspend\0icon\x1fsystem-suspend\nHibernate\0icon\x1fsystem-suspend-hibernate-alt2\nPower Off\0icon\x1fsystem-shutdown\nReboot\0icon\x1fsystem-reboot" | fuzzel --dmenu | tr --delete " " | tr "[:upper:]" "[:lower:]" | ifne xargs systemctl
    ''
    +
    ''
      animations {
          bezier = material_decelerate, 0.05, 0.7, 0.1,  1

          animation = windows,   1, 2 , material_decelerate, popin 80%
          animation = border ,   1, 10, default
          animation = fade   ,   1, 2 , default
          animation = workspaces,1, 3 , material_decelerate
      }
    ''
    +
    ''
      decoration {
        drop_shadow = false
        rounding    = ${toString cornerRadius}

        blur {
          enabled = false
        }
      }
    ''
    +
    ''
      general {
        gaps_in     = ${toString (margin/ 2)}
        gaps_out    = ${toString margin}
        border_size = ${toString borderWidth}

        col.active_border         = 0xFF${base0A}
        col.nogroup_border_active = 0xFF${base0A}

        col.inactive_border = 0xFF${base01}
        col.nogroup_border  = 0xFF${base01}

        cursor_inactive_timeout = 10
        no_cursor_warps         = true

        resize_on_border = true
      }
    ''
    +
    ''
      gestures {
        workspace_swipe = true
      }
    ''
    +
    ''
      input {
        follow_mouse = 1

        kb_layout = tr

        repeat_delay = 400
        repeat_rate  = 100

        touchpad {
          clickfinger_behavior = true
          drag_lock            = true

          natural_scroll = true
          scroll_factor  = 0.7
        }
      }
    ''
    +
    ''
      dwindle {
        preserve_split = true
        smart_resizing = false
      }
    ''
    +
    ''
      misc {
        animate_manual_resizes = true

        disable_hyprland_logo    = true
        disable_splash_rendering = true

        hide_cursor_on_key_press = true
        key_press_enables_dpms   = true
        mouse_move_enables_dpms  = true
      }
    '';
  };
})

(desktopHomePackages (with pkgs; [
  brightnessctl
  cliphist
  grim
  slurp
  swappy
  swaybg
  upkgs.hyprpicker
  wl-clipboard
  xdg-utils
  xwaylandvideobridge
]))
