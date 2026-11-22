# ~/devenvs/flake.nix
# One flake, many development shells. Usage:
#
#   nix develop ~/devenvs#esp        # ESP-IDF (all ESP32 chips)
#   nix develop ~/devenvs#arm        # bare-metal ARM (Cortex-M, 32-bit)
#
# Or per project, with direnv (auto-load on cd):
#   echo "use flake ~/devenvs#esp" > .envrc && direnv allow
#
# First time:  cd ~/devenvs && git init && git add flake.nix && nix flake lock
# Update all:  nix flake update   (versions are pinned in flake.lock)
# NOTE: flakes only see git-tracked files, so `git add` new files before using them.
 
{
  description = "My dev environments";
 
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
 
    esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
  };
 
  outputs = { self, nixpkgs, esp-dev }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
 
      buildTools = with pkgs; [ cmake ninja gnumake pkg-config ];
    in
    {
      devShells.${system} = {
 
        esp = esp-dev.devShells.${system}.esp-idf-full;
 
        # Bare-metal ARM (Cortex-M0..M85, 32-bit)
        arm = pkgs.mkShell {
          packages = buildTools ++ (with pkgs; [
            gcc-arm-embedded 
            arm-none-eabi-gcc newlib
            openocd probe-rs-tools stlink
            qemu               # qemu-system-arm -M lm3s6965evb / mps2-an385 ...
          ]);
        };
 
        # ARM Linux, 32-bit (armhf, e.g. RPi 2/3)
        armlinux32 = pkgs.pkgsCross.armv7l-hf-multiplatform.mkShell {
          nativeBuildInputs = buildTools ++ [ pkgs.qemu ];
        };
 
        # Windows x64 cross (MinGW-w64)
        win64 = pkgs.pkgsCross.mingwW64.mkShell {
          nativeBuildInputs = buildTools ++ [ pkgs.wineWowPackages.stable ];
        };
 
        # Python (venv managed by uv)
        python = pkgs.mkShell {
          packages = with pkgs; [ python3 uv ruff pyright ];
          shellHook = ''
            export UV_PYTHON_PREFERENCE=only-system
            [ -d .venv ] || uv venv -q
            source .venv/bin/activate
          '';
        };
      };
    };
}
