{
  pkgs,
  lib,
}: let
  jsonUtils = import ./json-utils.nix {inherit pkgs lib;};
in {
  inherit jsonUtils;
}
