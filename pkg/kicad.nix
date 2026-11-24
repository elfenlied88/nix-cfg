# /etc/nixos/pkg/kicad.nix
# Home Manager module: KiCad with the add-ons that nixpkgs packages.
{ pkgs, ... }:

{
  home.packages = [
    (pkgs.kicad.override {
      addons = with pkgs.kicadAddons; [
      ];
    })

    pkgs.gerbv # Gerber viewer: check the files before sending them to a manufacturer
    pkgs.ngspice # SPICE simulator on the command line

    pkgs.freecad
  ];
}
