let
  pkgs = ((builtins.getFlake (toString ./.)).legacyPackages.${builtins.currentSystem});
  pkgsCross = pkgs.pkgsCross.aarch64-multiplatform.__splicedPackages;
  lib = pkgs.lib;
  test = let
    pythonInNativeBuildInputs = lib.elemAt pkgsCross.python3Packages.xpybutil.nativeBuildInputs 0;
    overridenAttrsAttr = pkgsCross.hello.overrideAttrs (_: { something = "hello"; });
    #overridenAttr = pkgs.hello.override {}
    #overridenAttrsAttr = (pkgsCross.hello.overrideAttrs (previousAttrs: { something = "hello"; })) // { __spliced = { buildHost = { something = "hello"; }; };};
  in {
    shouldBeNative = pythonInNativeBuildInputs.stdenv.hostPlatform.system == "x86_64-linux";
    notCrossOverriden = pkgs.hello.overrideAttrs (_: _: { passthru = { o = "works"; }; });
    inherit overridenAttrsAttr;
    overridenAttrsAttrShouldHaveSplicedAndSomething = if overridenAttrsAttr ? __spliced then overridenAttrsAttr.something == overridenAttrsAttr.__spliced.buildHost.something else false;

  };
in
  assert test.shouldBeNative == true;
  assert test.overridenAttrsAttrShouldHaveSplicedAndSomething == true;
  assert test.notCrossOverriden.o == "works";
  test
