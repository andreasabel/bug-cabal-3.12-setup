
Cabal-3.12 passes include dirs in wrong order to GHC
====================================================

Conditions:
- GHC 9.10
- custom setup (can be default `Setup.hs`), so that `Cabal-3.12` is used
- building a `library` (not just an `executable`)
- using a build-tool: we use `happy` here to shadow a `.hs` file by a `.y` file

Files:
- `fred.cabal` with `build-type: Custom`
- `Setup.hs` (standard)
- `Fred.y`: processed by `happy`
- `Fred.hs`: stale code that should be shadowed by `Fred.y` always

In this setting `cabal v1-install` malfunctions if `ghc` is `ghc-9.10.1`.  (Works with older GHCs.)
It picks up `Fred.hs` instead of `dist/build/Fred.hs` that is created by `happy` from `Fred.y`.

Looking at the verbose output `cabal v1-install -v3`, we notice a difference in the call to `ghc` when the GHC is 9.10.1.

- GHC 9.10 / Cabal-3.12

        /usr/local/bin/ghc --make -fbuilding-cabal-package \
          ...
          -i. -idist/build \
          ... \
          Fred

        [1 of 2] Compiling Main ( Fred.hs, dist/build/Main.o, ...

- GHC 9.8 / Cabal-3.10

        /usr/local/bin/ghc --make -fbuilding-cabal-package \
          ... \
          -idist/build -i. \
          ... \
          Fred

        [1 of 1] Compiling Parser ( dist/build/Parser.hs, ... )

When building with GHC 9.8, library `Cabal-3.10` is used which places the path `dist/build` with the generated files correctly before the path `.` of the source files; but with GHC 9.10, library `Cabal-3.12` is used which does it the other way.

Full calls:

- GHC 9.10

        /usr/local/bin/ghc --make -fbuilding-cabal-package -O -static -dynamic-too -dynosuf dyn_o -dynhisuf dyn_hi \
          -outputdir dist/build -odir dist/build -hidir dist/build \
          -hiedir dist/build/extra-compilation-artifacts/hie \
          -stubdir dist/build -i \
          -i. -idist/build \
          -idist/build/autogen -idist/build/global-autogen \
          -Idist/build/autogen -Idist/build/global-autogen -Idist/build \
          -I/usr/local/opt/icu4c/include -I/usr/local/opt/libxml2/include/libxml2 \
          -optP-include -optPdist/build/autogen/cabal_macros.h \
          -this-unit-id stale-0-Ly26ql3fYpuLnJ9xynYGbf \
          -hide-all-packages -Wmissing-home-modules -package-db dist/package.conf.inplace \
          -package-id array-0.5.7.0-2002 -package-id base-4.20.0.0-8a80 \
          -XHaskell2010 \
          Fred

        [1 of 2] Compiling Main ( Fred.hs, dist/build/Main.o, ...

- GHC 9.8

        /usr/local/bin/ghc --make -fbuilding-cabal-package -O -static -dynamic-too -dynosuf dyn_o -dynhisuf dyn_hi \
          -outputdir dist/build -odir dist/build -hidir dist/build \
          -stubdir dist/build -i \
          -idist/build -i. \
          -idist/build/autogen -idist/build/global-autogen \
          -Idist/build/autogen -Idist/build/global-autogen -Idist/build \
          -I/usr/local/opt/icu4c/include -I/usr/local/opt/libxml2/include/libxml2 \
          -optP-include -optPdist/build/autogen/cabal_macros.h \
          -this-unit-id stale-0-F795SeGwWezHPbPW8onWYj \
          -hide-all-packages -Wmissing-home-modules -package-db dist/package.conf.inplace \
          -package-id array-0.5.6.0-28ee -package-id base-4.19.1.0-654f \
          -XHaskell2010 \
          Fred

        [1 of 1] Compiling Parser ( dist/build/Parser.hs, ... )
