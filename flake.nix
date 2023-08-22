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
        name = "europe-west3-docker.pkg.dev/stafftastic/images/webapp-base-image";
        copyToRoot = pkgs.buildEnv {
          name = "webapp-base";
          paths = with pkgs; [
            nodejs-16_x
            busybox
            curl
            dockerTools.binSh
            dockerTools.caCertificates
          ];
          pathsToLink = [ "/bin" ];
        };
        runAsRoot = ''
          #!/bin/sh
          corepack enable
          mkdir -p /app
        '';
        config = {
          Entrypoint = [ "/bin/sh" ];
          WorkingDir = "/app";
        };
      };
    });
  };
}