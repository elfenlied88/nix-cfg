# /etc/nixos/pkg/zed.nix

{
  pkgs,
  ...
}:

{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "toml"
      "make"
      "catppuccin"
    ];

    extraPackages = with pkgs; [
      nixd
      nixfmt-rfc-style
      clang-tools # clangd for C/C++
    ];

    userSettings = {
      theme = "Catppuccin Mocha";
      ui_font_size = 16;
      buffer_font_size = 14;
      buffer_font_family = "FiraCode Nerd Font";

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
          formatter.external.command = "nixfmt";
        };
      };
    };
  };
}
