{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    let
      overlay =
        final: prev: {
          dwm = prev.dwm.overrideAttrs (oldAttrs: rec {
            nativeBuildInputs =(oldAttrs.nativeBuildInputs or []) ++ [ prev.makeWrapper ];
            postPatch = (oldAttrs.postPatch or "") + ''
              cp -r DEF/* .
            '';
            version = "develop";
            src = ./.;
            # installPhase = ''
            # '' + (oldAttrs.installPhase or "");
            postInstall = (oldAttrs.installPhase or "") + ''
              wrapProgram $out/bin/dwm --set DWM_SCRIPTS_DIR "$out/bin/scripts"
              mkdir -p $out/bin/scripts
              cp -r DEF/* $out/bin/scripts
            '';
          });
        };
    in
    flake-utils.lib.eachDefaultSystem
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
            ];
          };
        in
        rec {
          packages.dwm = pkgs.dwm;
          packages.default = pkgs.dwm;
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [ xorg.libX11 xorg.libXft xorg.libXinerama gcc ];
          };
        }
      )
    // { overlays.default = overlay; };
}
