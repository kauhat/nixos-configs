{pkgs, ...}: let
  json5ToJsonDrv = json5String:
    pkgs.runCommand "converted.json" {
      inherit json5String;
      nativeBuildInputs = [pkgs.python3Packages.json5];
      passAsFile = ["json5String"];
    } "pyjson5 --as-json $json5StringPath > $out";

  fromJSON5 = json5String:
    builtins.fromJSON (builtins.readFile (json5ToJsonDrv json5String));

  #
  testFromJSON5 = let
    sampleJson5 = ''
      {
        // Single line comment
        unquotedKey: 'single quoted string',
        /* Multiline
           comment */
        numberVal: 42,
        arrayVal: [
          "item1",
          "item2", // trailing comma in array
        ],
      }
    '';

    # Expected equivalent Nix data structure
    expectedResult = {
      unquotedKey = "single quoted string";
      numberVal = 42;
      arrayVal = [
        "item1"
        "item2"
      ];
    };

    parsedFile = json5ToJsonDrv sampleJson5;
    expectedFile = pkgs.writeText "expected.json" (builtins.toJSON expectedResult);
  in
    pkgs.runCommand "test-fromJSON5" {
      nativeBuildInputs = [pkgs.diffutils pkgs.jq];
    } ''
      echo "Comparing parsed JSON5 output against expected structure..."
      if ! diff -u <(jq -S . ${parsedFile}) <(jq -S . ${expectedFile}); then
        echo "FAIL: parsed JSON5 structure does not match expected output!"
        exit 1
      fi
      echo "PASS: JSON5 parsed correctly!"
      touch $out
    '';
in {
  inherit fromJSON5 testFromJSON5;
}
