{ system ? builtins.currentSystem, ... }:
let
  pkgs = import <nixpkgs> {
    inherit system;
    config.allowUnfree = true;
  };
  unstable = import <nixos-unstable> {
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

  # Poniższe to wersja pakietu do VS Code która wrapuje Code tak, by
  # uruchamiał się w chroot'cie będącym compliant z Filesystem Hierarchy Standard,
  # poprzez konstrukt NixOSowy buildFHSUserEnv. Reintrodukuje to
  # katalogi takie jak /bin, /lib, czy /usr, niefunkcjonalne w NixOS,
  # przez co prekompilowane binarki z rozszerzeń Code czy pakietów Pythona
  # mogą działać bez konieczności ich indywidualnej "nixyfikacji".
  code = unstable.vscode-fhsWithPackages (ps: with ps; [
    # rustup zlib  # needed for rust lang server extension
    # (python39Full.withPackages (pp: with pp; [ pipenv ]))
    pipenv
    python39Full
    python310
  ]); # Kat, jeśli tu jesteś, to znaczy że niedługo możesz potrzebować
      # bym nauczyła Cię Dockera — do VS Code Remote: Containers
}
