{pkgs, ...} @ args: {
  fromJSON5 = json5File: let
    convertedJson = pkgs.runCommand "converted.json" {
      nativeBuildInputs = [pkgs.python3Packages.json5];
    } "pyjson5 --as-json ${json5File} > $out";
  in
    builtins.fromJSON (builtins.readFile convertedJson);

  # TODO
  # validateJSON5 = ...;
}
