{
  pkgs,
  lib,
  ...
} @ args: {
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
              # Lex the file using POSIX rules, filtering out comments
              tokens = shlex.split(f.read(), comments=True, posix=True)
              for token in tokens:
                  # Strip optional 'export ' prefix
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
}
