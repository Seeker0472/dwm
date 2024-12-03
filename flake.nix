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
            nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper prev.bear ];
            # postPatch = (oldAttrs.postPatch or "") + ''
            #   # cp -r DEF/* .
            # '';
            version = "develop";
            src = ./.;
            # installPhase = ''
            # '' + (oldAttrs.installPhase or "");
            postInstall = (oldAttrs.installPhase or "") + ''
              wrapProgram $out/bin/dwm --set DWM_SCRIPTS_DIR "$out/bin/scripts"
              mkdir -p $out/bin/scripts
              cp -r scripts/* $out/bin/scripts
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
          build_input=with pkgs; [ 
              clang-tools
              xorg.libX11 
              xorg.libXft 
              xorg.libXinerama 
              xorg.libxcb 
              xorg.libxcb 
              gcc 
              bear 
              pkgs.stdenv.cc.cc
            ];
        in
        rec {
          packages.dwm = pkgs.dwm;
          packages.default = pkgs.dwm;
          devShells.default = pkgs.mkShell {
            LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${pkgs.xorg.libxcb}/lib";
            buildInputs = build_input;
            CPATH = pkgs.lib.makeSearchPathOutput "dev" "include" build_input;
          };
        }
      )
    // { overlays.default = overlay; };
}
