{
  pkgs,
  lib,
}: let
  envUtils = import ./env-utils.nix {inherit pkgs lib;};
  jsonUtils = import ./json-utils.nix {inherit pkgs lib;};
in {
  inherit envUtils jsonUtils;
}
