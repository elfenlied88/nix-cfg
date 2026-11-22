{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    esptool
    espflash
  ];

  programs.zsh.shellAliases = {
    esp = "nix develop ~/devenvs#esp";
  };
}
