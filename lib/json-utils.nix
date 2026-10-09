{
  pkgs,
  lib,
  ...
} @ args: let
  fromJSON5 = json5String: let
    convertedJson = pkgs.runCommand "converted.json" {
      nativeBuildInputs = [pkgs.python3Packages.json5];
      passAsFile = ["json5String"];
      json5String = json5String;
    } "pyjson5 --as-json $json5StringPath > $out";
  in
    builtins.fromJSON (builtins.readFile convertedJson);

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

    # Parse the sample string via fromJSON5
    parsedResult = fromJSON5 sampleJson5;

    # Expected equivalent Nix data structure
    expectedResult = {
      unquotedKey = "single quoted string";
      numberVal = 42;
      arrayVal = [
        "item1"
        "item2"
      ];
    };

    parsedFile = pkgs.writeText "parsed.json" (builtins.toJSON parsedResult);
    expectedFile = pkgs.writeText "expected.json" (builtins.toJSON expectedResult);
  in
    pkgs.runCommand "test-fromJSON5" {
      nativeBuildInputs = [pkgs.diffutils];
    } ''
      echo "Comparing parsed JSON5 output against expected structure..."
      if ! diff -u ${parsedFile} ${expectedFile}; then
        echo "FAIL: parsed JSON5 structure does not match expected output!"
        exit 1
      fi
      echo "PASS: JSON5 parsed correctly!"
      touch $out
    '';
in {
  inherit fromJSON5 testFromJSON5;
}
