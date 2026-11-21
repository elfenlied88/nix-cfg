{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  user = userConfig.username;

in
{
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "26.05";

    packages = with pkgs; [
    ];

    shell.enableShellIntegration = true;
  };

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "FiraCode Nerd Font";
        font-size = 12;
        theme = "catppuccin-mocha";
      };
    };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/cfg/nvim";
}
