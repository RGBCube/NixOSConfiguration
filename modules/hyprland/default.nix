{ config, lib, pkgs, ... }: with lib; imports [

(desktopSystemConfiguration {
  hardware.opengl = enabled;

  xdg.portal = enabled {
    config.common.default = "*";

    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
    ];
  };
})

(desktopUserHomeConfiguration {
  wayland.windowManager.hyprland = enabled {
    settings = {
      monitor    = [ ",preferred,auto,1" ];
      windowrule = [ "noinitialfocus" ];

      exec-once = [
        "wl-paste --type text  --watch cliphist store -max-items 1000"
        "wl-paste --type image --watch cliphist store -max-items 1000"
      ];

      exec = [
        "pkill swaybg; swaybg --image ${./wallpaper.png}"
        "pkill --signal SIGUSR2 waybar"
      ];

      bindl = [
        (replaceStrings [ "\n;" "\n" ] [ ";" "" ] ''
          ,XF86PowerOff,exec,
          pkill fuzzel;
          echo -en "Suspend\0icon\x1fsystem-suspend\nHibernate\0icon\x1fsystem-suspend-hibernate-alt2\nPower Off\0icon\x1fsystem-shutdown\nReboot\0icon\x1fsystem-reboot"
          | fuzzel --dmenu
          | tr --delete " "
          | tr '[:upper:]' '[:lower:]'
          | ifne xargs systemctl
        '')
      ];

      bindle = [
        ",XF86AudioRaiseVolume , exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.5"
        ",XF86AudioLowerVolume , exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

        ",XF86AudioMute        , exec, wpctl set-mute @DEFAULT_AUDIO_SINK@   toggle"
        ",XF86AudioMicMute     , exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        ",XF86MonBrightnessUp  , exec, brightnessctl set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl set --min-value=0 5%-"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:274, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      binde = [
        "SUPER, left , movefocus, l"
        "SUPER, down , movefocus, d"
        "SUPER, up   , movefocus, u"
        "SUPER, right, movefocus, r"

        "SUPER, h, movefocus, l"
        "SUPER, j, movefocus, d"
        "SUPER, k, movefocus, u"
        "SUPER, l, movefocus, r"

        "SUPER+CTRL, left , resizeactive, -100 0"
        "SUPER+CTRL, down , resizeactive, 0 100"
        "SUPER+CTRL, up   , resizeactive, 0 -100"
        "SUPER+CTRL, right, resizeactive, 100 0"

        "SUPER+CTRL, h, resizeactive, -100 0"
        "SUPER+CTRL, j, resizeactive, 0 100"
        "SUPER+CTRL, k, resizeactive, 0 -100"
        "SUPER+CTRL, l, resizeactive, 100 0"
      ];

      bind = [
        "SUPER    , TAB, workspace, e+1"
        "SUPER+ALT, TAB, workspace, e-1"

        "SUPER, mouse_up,   workspace, e+1"
        "SUPER, mouse_down, workspace, e-1"

        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"

        "SUPER+ALT, 1, movetoworkspacesilent, 1"
        "SUPER+ALT, 2, movetoworkspacesilent, 2"
        "SUPER+ALT, 3, movetoworkspacesilent, 3"
        "SUPER+ALT, 4, movetoworkspacesilent, 4"
        "SUPER+ALT, 5, movetoworkspacesilent, 5"

        "SUPER+ALT, left , movewindow, l"
        "SUPER+ALT, down , movewindow, d"
        "SUPER+ALT, up   , movewindow, u"
        "SUPER+ALT, right, movewindow, r"

        "SUPER+ALT, h, movewindow, l"
        "SUPER+ALT, j, movewindow, d"
        "SUPER+ALT, k, movewindow, u"
        "SUPER+ALT, l, movewindow, r"
        
        "SUPER    , Q, killactive"
        "SUPER    , F, fullscreen"
        "SUPER+ALT, F, togglefloating"

        "SUPER+ALT, RETURN, exec, kitty"
        "SUPER    , RETURN, exec, ghostty --gtk-single-instance=true"
        "SUPER    , W     , exec, firefox"
        "SUPER    , D     , exec, discord"
        "SUPER    , E     , exec, fractal"
        "SUPER    , M     , exec, thunderbird"
        "SUPER    , T     , exec, thunar"
        "SUPER    , C     , exec, hyprpicker --autocopy"

        "SUPER, B, exec, pkill --signal SIGUSR1 waybar"
        "SUPER, SPACE, exec, pkill fuzzel; fuzzel"
        "SUPER, V    , exec, pkill fuzzel; cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"

        "   , PRINT, exec, pkill grim; grim -g \"$(slurp -w 0)\" - | swappy -f - -o - | wl-copy --type image/png"
        "ALT, PRINT, exec, pkill grim; grim                      - | swappy -f - -o - | wl-copy --type image/png"
      ];

      general = with config.theme; {
        gaps_in     = margin / 2;
        gaps_out    = margin;
        border_size = borderWidth;

        "col.active_border"         = "0xFF${base0A}";
        "col.nogroup_border_active" = "0xFF${base0A}";

        "col.inactive_border" = "0xFF${base01}";
        "col.nogroup_border"  = "0xFF${base01}";

        cursor_inactive_timeout = 10;
        no_cursor_warps         = true;

        resize_on_border = true;
      };

      decoration = {
        drop_shadow = false;
        rounding    = config.theme.cornerRadius;

        blur.enabled = false;
      };

      input = {
        follow_mouse = 1;

        kb_layout = "tr";

        repeat_delay = 400;
        repeat_rate  = 100;

        touchpad = {
          clickfinger_behavior = true;
          drag_lock            = true;

          natural_scroll = true;
          scroll_factor  = 0.7;
        };
      };

      gestures.workspace_swipe = true;

      animations = {
        bezier = [ "material_decelerate,0.05,0.7,0.1,1" ];

        animation = [
          "border    , 1, 10, material_decelerate"
          "fade      , 1, 2 , material_decelerate"
          "layers    , 1, 2 , material_decelerate"
          "windows   , 1, 2 , material_decelerate, popin 80%"
          "workspaces, 1, 3 , material_decelerate"
        ];
      };

      misc = {
        animate_manual_resizes = true;

        disable_hyprland_logo    = true;
        disable_splash_rendering = true;

        hide_cursor_on_key_press = true;
        key_press_enables_dpms   = true;
        mouse_move_enables_dpms  = true;
      };

      dwindle = {
        preserve_split = true;
        smart_resizing = false;
      };
    };
  };
})

(desktopUserHomePackages (with pkgs; [
  brightnessctl
  cliphist
  grim
  hyprpicker
  slurp
  swappy
  swaybg
  wl-clipboard
  xdg-utils
  xwaylandvideobridge
]))

]
