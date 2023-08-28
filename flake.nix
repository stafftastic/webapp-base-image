{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, systems }:
  let
    lib = nixpkgs.lib;
    eachSystem = lib.genAttrs (import systems);
    pkgsFor = eachSystem (system: nixpkgs.legacyPackages.${system});
  in {
    packages = eachSystem (system:
    let
      pkgs = pkgsFor.${system};
    in {
      default = pkgs.dockerTools.buildImage {
        name = "webapp-base-image";
        tag = "local";
        copyToRoot = pkgs.buildEnv {
          name = "webapp-base";
          paths = with pkgs; [
            nodejs-16_x
            busybox
            curl
            dockerTools.binSh
            dockerTools.usrBinEnv
            dockerTools.caCertificates
          ];
        };
        runAsRoot = ''
          #!/bin/sh
          corepack enable
          mkdir -p /app
        '';
        config = {
          Entrypoint = [ "/bin/sh" "-c" ];
          WorkingDir = "/app";
        };
      };
    });
  };
}
