{
  pkgs,
  lib,
  ...
} @ args: let
  # TODO: test this?
  fromJSON5 = json5String: let
    convertedJson = pkgs.runCommand "converted.json" {
      nativeBuildInputs = [pkgs.python3Packages.json5];
      passAsFile = ["json5String"];
      json5String = json5String;
    } "pyjson5 --as-json $json5StringPath > $out";
  in
    builtins.fromJSON (builtins.readFile convertedJson);
  # TODO
  # validateJSON5 = ...;
in {
  inherit getEnvValue testEnvUtils;
}
