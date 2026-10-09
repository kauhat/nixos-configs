{
  pkgs,
  lib,
  ...
} @ args: let
  # Parses KEY from a dotenv file using Python's standard library shlex parser.
  # Handles single/double quotes, escaped characters, and comments (#).
  getEnvValue = key: file: let
    pythonScript = ''
      import shlex, sys, os
      file_path = "${file}"
      target_key = "${key}"

      if not os.path.exists(file_path):
          sys.exit(0)

      try:
          with open(file_path, "r") as f:
              tokens = shlex.split(f.read(), comments=True, posix=True)
              for token in tokens:
                  if token.startswith("export "):
                      token = token[7:]
                  if "=" in token:
                      k, v = token.split("=", 1)
                      if k.strip() == target_key:
                          print(v)
                          sys.exit(0)
      except Exception:
          sys.exit(0)
    '';
  in "$(${pkgs.python3}/bin/python3 -c ${lib.escapeShellArg pythonScript} 2>/dev/null)";

  testEnvUtils = let
    sampleEnvFile = pkgs.writeText "sample.env" ''
      # Comment line
      PLAIN_KEY=plain_value
      SINGLE_QUOTED='single quoted value'
      DOUBLE_QUOTED="double quoted value"
      export EXPORTED_KEY="exported_value" # inline comment
      # COMMENTED_KEY=commented_out
    '';
  in
    pkgs.runCommand "test-getEnvValue" {
      nativeBuildInputs = [pkgs.python3];
    } ''
      echo "Running getEnvValue integration test..."

      TEST_PLAIN="${getEnvValue "PLAIN_KEY" sampleEnvFile}"
      TEST_SINGLE="${getEnvValue "SINGLE_QUOTED" sampleEnvFile}"
      TEST_DOUBLE="${getEnvValue "DOUBLE_QUOTED" sampleEnvFile}"
      TEST_EXPORT="${getEnvValue "EXPORTED_KEY" sampleEnvFile}"
      TEST_MISSING="${getEnvValue "MISSING_KEY" sampleEnvFile}"
      TEST_COMMENTED="${getEnvValue "COMMENTED_KEY" sampleEnvFile}"

      fail=0

      assert_eq() {
        local name="$1"
        local expected="$2"
        local actual="$3"
        if [ "$expected" != "$actual" ]; then
          echo "FAIL [$name]: expected '$expected', got '$actual'"
          fail=1
        else
          echo "PASS [$name]: '$actual'"
        fi
      }

      assert_eq "Plain value" "plain_value" "$TEST_PLAIN"
      assert_eq "Single quoted value" "single quoted value" "$TEST_SINGLE"
      assert_eq "Double quoted value" "double quoted value" "$TEST_DOUBLE"
      assert_eq "Exported value" "exported_value" "$TEST_EXPORT"
      assert_eq "Missing key" "" "$TEST_MISSING"
      assert_eq "Commented key" "" "$TEST_COMMENTED"

      if [ "$fail" -eq 1 ]; then
        exit 1
      fi

      echo "All tests passed!"
      touch $out
    '';
in {
  inherit getEnvValue testEnvUtils;
}
