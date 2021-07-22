{ system ? builtins.currentSystem, ... }:
let
  pkgs = import <nixpkgs> {
    inherit system;
    config.allowUnfree = true;
  };
in
rec {
  base = with pkgs; [
    firefox
    file
  ];
  the_steam = pkgs.steam.override {
        extraLibraries = pkgs: with pkgs;
          [
            libxkbcommon
            mesa
            #wayland
            #(sndio.overrideAttrs (old: {
            #  postFixup = old.postFixup + ''
            #    ln -s $out/lib/libsndio.so $out/lib/libsndio.so.6.1
            #  '';
            #}))
            pipewire
          ];
      };
  sztim = with pkgs; [
    the_steam
    the_steam.run
#    steam-run
#    steam-run-native
  ];
  cdda = pkgs.cataclysm-dda.withMods [
    pkgs.cataclysm-dda.pkgs.tileset.UndeadPeople
  ];
}
