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
  imports = [
    ../pkg/zed.nix
    ../pkg/ghidra.nix
    ../pkg/rust.nix
    ../pkg/esp.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "26.05";

    packages = with pkgs; [
      minicom picocom
      bat eza fzf zoxide
      lazygit delta
      tmux
      ncdu tldr hexyl
      dive
      (rpi-imager.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          sed -i '0,/^import QtQuick$/s//import QtQuick\nimport QtQuick.Controls.Material/' src/wizard/WritingStep.qml
          grep -q 'Controls.Material' src/wizard/WritingStep.qml
      '';
      }))
    ];

    shell.enableShellIntegration = true;
  };

  programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
  };
  services.ssh-agent.enable = true;
  programs.ssh.settings = {
    enable = true;
    addKeysToAgent = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      test-nix = "sudo nixos-rebuild test";
    };
    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;     # no blank line between prompts
    };
  };

  programs.ghostty = {
    enable = true;
      settings = {
        font-family = "FiraCode Nerd Font";
        font-size = 12;
        theme = "Catppuccin Mocha";
      };
      keybind = [ 
        "ctrl+alt+1=goto_tab:1" 
        "ctrl+alt+2=goto_tab:2" 
        "ctrl+alt+1=goto_tab:3" 
        "ctrl+alt+2=goto_tab:4" 
        "ctrl+alt+1=goto_tab:5" 
        "ctrl+alt+2=goto_tab:6" 
        "ctrl+alt+1=goto_tab:7" 
        "ctrl+alt+2=goto_tab:8" 
        "ctrl+alt+1=goto_tab:9" 
      ];
    };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/cfg/nvim";
  home.file."devenvs".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nixos/cfg/devenvs";
}
