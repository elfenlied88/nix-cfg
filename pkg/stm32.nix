{ pkgs, ... }:

let
  unstable =
    import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz")
      {
        config.allowUnfree = true;
      };
in
{
  home.packages = [
    unstable.stm32cubemx
  ]
  ++ (with pkgs; [
    gcc-arm-embedded
    openocd
    stlink
    dfu-util
    stm32flash
    probe-rs-tools
    picocom
  ]);
}
