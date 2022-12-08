let
  overlay = self: super: {
    luajit =
      let
        packageOverrides = self: super: rec {
          box = self.callPackage ./pkgs/lua-modules/box { inherit exc; };
          exc = self.callPackage ./pkgs/lua-modules/exc { };
        };
      in
      super.luajit.override {
        inherit packageOverrides;
        self = self.luajit;
      };
  };

  nixpkgs = import ./. { overlays = [ overlay ]; };
in
nixpkgs.luajit.pkgs.box
