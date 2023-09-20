{ nodejs-16_x
, busybox
, curl
, buildEnv
, dockerTools
, imageName ? "webapp-base-image"
, imageTag ? "local"
, extraEnv ? []
, extraPkgs ? []
}: let
  bin = buildEnv {
    name = "bin";
    paths = [
      busybox
      curl
      nodejs-16_x
    ];
    pathsToLink = [ "/bin" ];
  };
in dockerTools.buildImage {
  name = imageName;
  tag = imageTag;
  copyToRoot = buildEnv {
    name = "webapp-base";
    paths = with dockerTools; [
      bin
      usrBinEnv
      caCertificates
    ] ++ extraPkgs;
  };
  runAsRoot = ''
    #!/bin/sh
    mkdir -pm1777 /tmp
    mkdir -p /app
    corepack enable
  '';
  config = {
    Cmd = [ "/bin/sh" ];
    WorkingDir = "/app";
    Env = [
      "NODE_OPTIONS=--openssl-legacy-provider"
    ] ++ extraEnv;
  };
}
