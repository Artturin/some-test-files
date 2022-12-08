let
  pkgs = ((builtins.getFlake "nixpkgs").legacyPackages.${builtins.currentSystem});
  pkgsNoStructured = import ./. { config = { structuredAttrsByDefault = false; }; };
  pkgsStructured = import ./. { config = { structuredAttrsByDefault = true; }; };

  expand-response-params = pkgsNoStructured.stdenv.__bootPackages.stdenv.__bootPackages.stdenv.__bootPackages.stdenv.cc.expand-response-params.overrideAttrs (previousAttrs: {
    buildPhase = ''
      dumpVars
      cp $NIX_BUILD_TOP/env-vars $out
      true
      exit
    '';
  });
  expand-response-params-structured = pkgsStructured.stdenv.__bootPackages.stdenv.__bootPackages.stdenv.__bootPackages.stdenv.cc.expand-response-params.overrideAttrs (previousAttrs: {
    name = "expand-response-params-structured";
    buildPhase = ''
      dumpVars
      cp $NIX_BUILD_TOP/env-vars $out
      true
      exit
    '';
  });
in
pkgs.runCommand "compare-env-vars"
{ nativeBuildInputs = [ pkgs.diffoscope ]; passthru = { inherit expand-response-params expand-response-params-structured;}; } ''
  mkdir -p $out
  cp ${expand-response-params} $out/not-structured
  cp ${expand-response-params-structured} $out/structured
  chmod -R +w $out
  sort -o $out/not-structured{,}
  sort -o $out/structured{,}
  # remove hashes so diff works better
  sed 's|/nix/store/.\{33\}||g' -i $out/not-structured
  sed 's|/nix/store/.\{33\}||g' -i $out/structured
  diffoscope $out/not-structured $out/structured
''
