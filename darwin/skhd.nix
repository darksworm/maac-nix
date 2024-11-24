{ config, lib, pkgs, ... }:

let
  skhdOverlay = import ./skhd-overlay.nix;
  pkgsWithSkhd = pkgs // skhdOverlay pkgs;
in

{
  environment.systemPackages = with pkgsWithSkhd; [
    skhd
  ];

  services.skhd = {
    enable = true;
    skhdConfig = ''
      #change focus between external displays (left and right)
      lalt - s: yabai -m display --focus west
      lalt - g: yabai -m display --focus east

      cmd - return : /etc/profiles/per-user/ilmars/bin/alacritty
      lalt - c : osascript -e 'tell application "Arc" to make new window'

      shift + lalt - 0 : yabai -m space --balance
      shift + lalt - h : yabai -m window --resize left:-20:0
      shift + lalt - l : yabai -m window --resize right:20:0

      # move managed window
      shift + cmd - h : yabai -m window --warp west
      shift + cmd - l : yabai -m window --warp east
      shift + cmd - j : yabai -m window --warp south
      shift + cmd - k : yabai -m window --warp north

      # move window to space #
      shift + lalt - 1 : yabai -m window --space 1;
      shift + lalt - 2 : yabai -m window --space 2;
      shift + lalt - 3 : yabai -m window --space 3;
      shift + lalt - 4 : yabai -m window --space 4;
      shift + lalt - 5 : yabai -m window --space 5;
      shift + lalt - 6 : yabai -m window --space 6;
      shift + lalt - 7 : yabai -m window --space 7;
      shift + lalt - 7 : yabai -m window --space 8;

      lalt - 1 : yabai -m space --focus 1
      lalt - 2 : yabai -m space --focus 2
      lalt - 3 : yabai -m space --focus 3
      lalt - 4 : yabai -m space --focus 4
      lalt - 5 : yabai -m space --focus 5
      lalt - 6 : yabai -m space --focus 6
      lalt - 7 : yabai -m space --focus 7
      lalt - 8 : yabai -m space --focus 8

      lalt - j : yabai -m window --focus south
      lalt - k : yabai -m window --focus north
      lalt - h : yabai -m window --focus west
      lalt - l : yabai -m window --focus east

      # move window and split
      ctrl + lalt - j : yabai -m window --warp south
      ctrl + lalt - k : yabai -m window --warp north
      ctrl + lalt - h : yabai -m window --warp west
      ctrl + lalt - l : yabai -m window --warp east

      shift + lalt - h : yabai -m window --swap north
      shift + lalt - l : yabai -m window --swap north

      lalt - f : yabai -m window --toggle zoom-fullscreen

      # toggle window split type
      lalt - e : yabai -m window --toggle split

      # float / unfloat window and center on screen
      lalt - t : yabai -m window --toggle float --grid 4:4:1:1:2:2

      lalt + shift - q : yabai -m window --close

      ## things maybe useful

      # focus monitor
      # ctrl + lalt - z  : yabai -m display --focus prev
      # ctrl + lalt - 3  : yabai -m display --focus 3
    '';
  };
}
