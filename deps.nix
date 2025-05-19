{
  pkgs,
  lib,
  beamPackages,
  overrides ? (_x: _y: { }),
}:

let
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;

  workarounds = {
    portCompiler = _unusedArgs: _old: {
      buildPlugins = [ pkgs.beamPackages.pc ];
    };

    rustlerPrecompiled =
      {
        toolchain ? null,
        ...
      }:
      old:
      let
        extendedPkgs = pkgs.extend fenixOverlay;
        fenixOverlay = import "${
          fetchTarball {
            url = "https://github.com/nix-community/fenix/archive/056c9393c821a4df356df6ce7f14c722dc8717ec.tar.gz";
            sha256 = "sha256:1cdfh6nj81gjmn689snigidyq7w98gd8hkl5rvhly6xj7vyppmnd";
          }
        }/overlay.nix";
        nativeDir = "${old.src}/native/${with builtins; head (attrNames (readDir "${old.src}/native"))}";
        fenix =
          if toolchain == null then
            extendedPkgs.fenix.stable
          else
            extendedPkgs.fenix.fromToolchainName toolchain;
        native =
          (extendedPkgs.makeRustPlatform {
            inherit (fenix) cargo rustc;
          }).buildRustPackage
            {
              pname = "${old.packageName}-native";
              version = old.version;
              src = nativeDir;
              cargoLock = {
                lockFile = "${nativeDir}/Cargo.lock";
              };
              nativeBuildInputs = [
                extendedPkgs.cmake
              ] ++ extendedPkgs.lib.lists.optional extendedPkgs.stdenv.isDarwin extendedPkgs.darwin.IOKit;
              doCheck = false;
            };

      in
      {
        nativeBuildInputs = [ extendedPkgs.cargo ];

        env.RUSTLER_PRECOMPILED_FORCE_BUILD_ALL = "true";
        env.RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH = "unused-but-required";

        preConfigure = ''
          mkdir -p priv/native
          for lib in ${native}/lib/*
          do
            ln -s "$lib" "priv/native/$(basename "$lib")"
          done
        '';

        buildPhase = ''
          suggestion() {
            echo "***********************************************"
            echo "                 deps_nix                      "
            echo
            echo " Rust dependency build failed.                 "
            echo
            echo " If you saw network errors, you might need     "
            echo " to disable compilation on the appropriate     "
            echo " RustlerPrecompiled module in your             "
            echo " application config.                           "
            echo
            echo " We think you need this:                       "
            echo
            echo -n " "
            grep -Rl 'use RustlerPrecompiled' lib \
              | xargs grep 'defmodule' \
              | sed 's/defmodule \(.*\) do/config :${old.packageName}, \1, skip_compilation?: true/'
            echo "***********************************************"
            exit 1
          }
          trap suggestion ERR
          ${old.buildPhase}
        '';
      };
  };

  defaultOverrides = (
    _final: prev:

    let
      apps = {
        crc32cer = [
          {
            name = "portCompiler";
          }
        ];
        explorer = [
          {
            name = "rustlerPrecompiled";
            toolchain = {
              name = "nightly-2024-11-01";
              sha256 = "sha256-wq7bZ1/IlmmLkSa3GUJgK17dTWcKyf5A+ndS9yRwB88=";
            };
          }
        ];
        snappyer = [
          {
            name = "portCompiler";
          }
        ];
      };

      applyOverrides =
        appName: drv:
        let
          allOverridesForApp = builtins.foldl' (
            acc: workaround: acc // (workarounds.${workaround.name} workaround) drv
          ) { } apps.${appName};

        in
        if builtins.hasAttr appName apps then drv.override allOverridesForApp else drv;

    in
    builtins.mapAttrs applyOverrides prev
  );

  self = packages // (defaultOverrides self packages) // (overrides self packages);

  packages =
    with beamPackages;
    with self;
    {

      argon2_elixir =
        let
          version = "3.2.1";
          drv = buildMix {
            inherit version;
            name = "argon2_elixir";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "argon2_elixir";
              sha256 = "a813b78217394530b5fcf4c8070feee43df03ffef938d044019169c766315690";
            };

            beamDeps = [
              comeonin
              elixir_make
            ];
          };
        in
        drv;

      bandit =
        let
          version = "1.6.11";
          drv = buildMix {
            inherit version;
            name = "bandit";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bandit";
              sha256 = "543f3f06b4721619a1220bed743aa77bf7ecc9c093ba9fab9229ff6b99eacc65";
            };

            beamDeps = [
              hpax
              plug
              telemetry
              thousand_island
              websock
            ];
          };
        in
        drv;

      bunt =
        let
          version = "1.0.0";
          drv = buildMix {
            inherit version;
            name = "bunt";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bunt";
              sha256 = "dc5f86aa08a5f6fa6b8096f0735c4e76d54ae5c9fa2c143e5a1fc7c1cd9bb6b5";
            };
          };
        in
        drv;

      castore =
        let
          version = "1.0.13";
          drv = buildMix {
            inherit version;
            name = "castore";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "castore";
              sha256 = "ec09e81a9c3db92d27c6651d119d8adc6d1cbbb3d90f8c1293eee2af590bf55d";
            };
          };
        in
        drv;

      comeonin =
        let
          version = "5.5.1";
          drv = buildMix {
            inherit version;
            name = "comeonin";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "comeonin";
              sha256 = "65aac8f19938145377cee73973f192c5645873dcf550a8a6b18187d17c13ccdb";
            };
          };
        in
        drv;

      credo =
        let
          version = "1.7.12";
          drv = buildMix {
            inherit version;
            name = "credo";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "credo";
              sha256 = "8493d45c656c5427d9c729235b99d498bd133421f3e0a683e5c1b561471291e5";
            };

            beamDeps = [
              bunt
              file_system
              jason
            ];
          };
        in
        drv;

      db_connection =
        let
          version = "2.7.0";
          drv = buildMix {
            inherit version;
            name = "db_connection";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "db_connection";
              sha256 = "dcf08f31b2701f857dfc787fbad78223d61a32204f217f15e881dd93e4bdd3ff";
            };

            beamDeps = [
              telemetry
            ];
          };
        in
        drv;

      decimal =
        let
          version = "2.3.0";
          drv = buildMix {
            inherit version;
            name = "decimal";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "decimal";
              sha256 = "a4d66355cb29cb47c3cf30e71329e58361cfcb37c34235ef3bf1d7bf3773aeac";
            };
          };
        in
        drv;

      dns_cluster =
        let
          version = "0.1.3";
          drv = buildMix {
            inherit version;
            name = "dns_cluster";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "dns_cluster";
              sha256 = "46cb7c4a1b3e52c7ad4cbe33ca5079fbde4840dedeafca2baf77996c2da1bc33";
            };
          };
        in
        drv;

      earmark_parser =
        let
          version = "1.4.44";
          drv = buildMix {
            inherit version;
            name = "earmark_parser";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "earmark_parser";
              sha256 = "4778ac752b4701a5599215f7030989c989ffdc4f6df457c5f36938cc2d2a2750";
            };
          };
        in
        drv;

      ecto =
        let
          version = "3.12.5";
          drv = buildMix {
            inherit version;
            name = "ecto";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ecto";
              sha256 = "6eb18e80bef8bb57e17f5a7f068a1719fbda384d40fc37acb8eb8aeca493b6ea";
            };

            beamDeps = [
              decimal
              jason
              telemetry
            ];
          };
        in
        drv;

      ecto_sql =
        let
          version = "3.12.1";
          drv = buildMix {
            inherit version;
            name = "ecto_sql";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ecto_sql";
              sha256 = "aff5b958a899762c5f09028c847569f7dfb9cc9d63bdb8133bff8a5546de6bf5";
            };

            beamDeps = [
              db_connection
              ecto
              postgrex
              telemetry
            ];
          };
        in
        drv;

      elixir_make =
        let
          version = "0.9.0";
          drv = buildMix {
            inherit version;
            name = "elixir_make";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "elixir_make";
              sha256 = "db23d4fd8b757462ad02f8aa73431a426fe6671c80b200d9710caf3d1dd0ffdb";
            };
          };
        in
        drv;

      esbuild =
        let
          version = "0.9.0";
          drv = buildMix {
            inherit version;
            name = "esbuild";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "esbuild";
              sha256 = "b415027f71d5ab57ef2be844b2a10d0c1b5a492d431727f43937adce22ba45ae";
            };

            beamDeps = [
              jason
            ];
          };
        in
        drv;

      ex_doc =
        let
          version = "0.38.1";
          drv = buildMix {
            inherit version;
            name = "ex_doc";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_doc";
              sha256 = "754636236d191b895e1e4de2ebb504c057fe1995fdfdd92e9d75c4b05633008b";
            };

            beamDeps = [
              earmark_parser
              makeup_elixir
              makeup_erlang
            ];
          };
        in
        drv;

      expo =
        let
          version = "1.1.0";
          drv = buildMix {
            inherit version;
            name = "expo";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "expo";
              sha256 = "fbadf93f4700fb44c331362177bdca9eeb8097e8b0ef525c9cc501cb9917c960";
            };
          };
        in
        drv;

      file_system =
        let
          version = "1.1.0";
          drv = buildMix {
            inherit version;
            name = "file_system";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "file_system";
              sha256 = "bfcf81244f416871f2a2e15c1b515287faa5db9c6bcf290222206d120b3d43f6";
            };
          };
        in
        drv;

      finch =
        let
          version = "0.19.0";
          drv = buildMix {
            inherit version;
            name = "finch";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "finch";
              sha256 = "fc5324ce209125d1e2fa0fcd2634601c52a787aff1cd33ee833664a5af4ea2b6";
            };

            beamDeps = [
              mime
              mint
              nimble_options
              nimble_pool
              telemetry
            ];
          };
        in
        drv;

      floki =
        let
          version = "0.37.1";
          drv = buildMix {
            inherit version;
            name = "floki";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "floki";
              sha256 = "673d040cb594d31318d514590246b6dd587ed341d3b67e17c1c0eb8ce7ca6f04";
            };
          };
        in
        drv;

      gettext =
        let
          version = "0.26.2";
          drv = buildMix {
            inherit version;
            name = "gettext";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "gettext";
              sha256 = "aa978504bcf76511efdc22d580ba08e2279caab1066b76bb9aa81c4a1e0a32a5";
            };

            beamDeps = [
              expo
            ];
          };
        in
        drv;

      heroicons = pkgs.fetchFromGitHub {
        owner = "tailwindlabs";
        repo = "heroicons";
        rev = "88ab3a0d790e6a47404cba02800a6b25d2afae50";
        hash = "sha256-4yRqfY8r2Ar9Fr45ikD/8jK+H3g4veEHfXa9BorLxXg=";
      };

      hpax =
        let
          version = "1.0.3";
          drv = buildMix {
            inherit version;
            name = "hpax";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "hpax";
              sha256 = "8eab6e1cfa8d5918c2ce4ba43588e894af35dbd8e91e6e55c817bca5847df34a";
            };
          };
        in
        drv;

      jason =
        let
          version = "1.4.4";
          drv = buildMix {
            inherit version;
            name = "jason";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "jason";
              sha256 = "c5eb0cab91f094599f94d55bc63409236a8ec69a21a67814529e8d5f6cc90b3b";
            };

            beamDeps = [
              decimal
            ];
          };
        in
        drv;

      makeup =
        let
          version = "1.2.1";
          drv = buildMix {
            inherit version;
            name = "makeup";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup";
              sha256 = "d36484867b0bae0fea568d10131197a4c2e47056a6fbe84922bf6ba71c8d17ce";
            };

            beamDeps = [
              nimble_parsec
            ];
          };
        in
        drv;

      makeup_elixir =
        let
          version = "1.0.1";
          drv = buildMix {
            inherit version;
            name = "makeup_elixir";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_elixir";
              sha256 = "7284900d412a3e5cfd97fdaed4f5ed389b8f2b4cb49efc0eb3bd10e2febf9507";
            };

            beamDeps = [
              makeup
              nimble_parsec
            ];
          };
        in
        drv;

      makeup_erlang =
        let
          version = "1.0.2";
          drv = buildMix {
            inherit version;
            name = "makeup_erlang";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_erlang";
              sha256 = "af33ff7ef368d5893e4a267933e7744e46ce3cf1f61e2dccf53a111ed3aa3727";
            };

            beamDeps = [
              makeup
            ];
          };
        in
        drv;

      mime =
        let
          version = "2.0.7";
          drv = buildMix {
            inherit version;
            name = "mime";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mime";
              sha256 = "6171188e399ee16023ffc5b76ce445eb6d9672e2e241d2df6050f3c771e80ccd";
            };
          };
        in
        drv;

      mint =
        let
          version = "1.7.1";
          drv = buildMix {
            inherit version;
            name = "mint";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mint";
              sha256 = "fceba0a4d0f24301ddee3024ae116df1c3f4bb7a563a731f45fdfeb9d39a231b";
            };

            beamDeps = [
              castore
              hpax
            ];
          };
        in
        drv;

      mix_audit =
        let
          version = "2.1.4";
          drv = buildMix {
            inherit version;
            name = "mix_audit";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mix_audit";
              sha256 = "fd807653cc8c1cada2911129c7eb9e985e3cc76ebf26f4dd628bb25bbcaa7099";
            };

            beamDeps = [
              jason
              yaml_elixir
            ];
          };
        in
        drv;

      nimble_options =
        let
          version = "1.1.1";
          drv = buildMix {
            inherit version;
            name = "nimble_options";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "nimble_options";
              sha256 = "821b2470ca9442c4b6984882fe9bb0389371b8ddec4d45a9504f00a66f650b44";
            };
          };
        in
        drv;

      nimble_parsec =
        let
          version = "1.4.2";
          drv = buildMix {
            inherit version;
            name = "nimble_parsec";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "nimble_parsec";
              sha256 = "4b21398942dda052b403bbe1da991ccd03a053668d147d53fb8c4e0efe09c973";
            };
          };
        in
        drv;

      nimble_pool =
        let
          version = "1.1.0";
          drv = buildMix {
            inherit version;
            name = "nimble_pool";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "nimble_pool";
              sha256 = "af2e4e6b34197db81f7aad230c1118eac993acc0dae6bc83bac0126d4ae0813a";
            };
          };
        in
        drv;

      phoenix =
        let
          version = "1.7.21";
          drv = buildMix {
            inherit version;
            name = "phoenix";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix";
              sha256 = "336dce4f86cba56fed312a7d280bf2282c720abb6074bdb1b61ec8095bdd0bc9";
            };

            beamDeps = [
              castore
              jason
              phoenix_pubsub
              phoenix_template
              plug
              plug_crypto
              telemetry
              websock_adapter
            ];
          };
        in
        drv;

      phoenix_ecto =
        let
          version = "4.6.4";
          drv = buildMix {
            inherit version;
            name = "phoenix_ecto";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_ecto";
              sha256 = "f5b8584c36ccc9b903948a696fc9b8b81102c79c7c0c751a9f00cdec55d5f2d7";
            };

            beamDeps = [
              ecto
              phoenix_html
              plug
              postgrex
            ];
          };
        in
        drv;

      phoenix_html =
        let
          version = "4.2.1";
          drv = buildMix {
            inherit version;
            name = "phoenix_html";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_html";
              sha256 = "cff108100ae2715dd959ae8f2a8cef8e20b593f8dfd031c9cba92702cf23e053";
            };
          };
        in
        drv;

      phoenix_live_dashboard =
        let
          version = "0.8.7";
          drv = buildMix {
            inherit version;
            name = "phoenix_live_dashboard";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_live_dashboard";
              sha256 = "3a8625cab39ec261d48a13b7468dc619c0ede099601b084e343968309bd4d7d7";
            };

            beamDeps = [
              ecto
              mime
              phoenix_live_view
              telemetry_metrics
            ];
          };
        in
        drv;

      phoenix_live_view =
        let
          version = "1.0.11";
          drv = buildMix {
            inherit version;
            name = "phoenix_live_view";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_live_view";
              sha256 = "522b8c164d1a0009d30fd3364538d17684cb6f8e6a6931f511f82d891c634cdd";
            };

            beamDeps = [
              floki
              jason
              phoenix
              phoenix_html
              phoenix_template
              plug
              telemetry
            ];
          };
        in
        drv;

      phoenix_pubsub =
        let
          version = "2.1.3";
          drv = buildMix {
            inherit version;
            name = "phoenix_pubsub";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_pubsub";
              sha256 = "bba06bc1dcfd8cb086759f0edc94a8ba2bc8896d5331a1e2c2902bf8e36ee502";
            };
          };
        in
        drv;

      phoenix_template =
        let
          version = "1.0.4";
          drv = buildMix {
            inherit version;
            name = "phoenix_template";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_template";
              sha256 = "2c0c81f0e5c6753faf5cca2f229c9709919aba34fab866d3bc05060c9c444206";
            };

            beamDeps = [
              phoenix_html
            ];
          };
        in
        drv;

      plug =
        let
          version = "1.17.0";
          drv = buildMix {
            inherit version;
            name = "plug";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "plug";
              sha256 = "f6692046652a69a00a5a21d0b7e11fcf401064839d59d6b8787f23af55b1e6bc";
            };

            beamDeps = [
              mime
              plug_crypto
              telemetry
            ];
          };
        in
        drv;

      plug_crypto =
        let
          version = "2.1.1";
          drv = buildMix {
            inherit version;
            name = "plug_crypto";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "plug_crypto";
              sha256 = "6470bce6ffe41c8bd497612ffde1a7e4af67f36a15eea5f921af71cf3e11247c";
            };
          };
        in
        drv;

      postgrex =
        let
          version = "0.20.0";
          drv = buildMix {
            inherit version;
            name = "postgrex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "postgrex";
              sha256 = "d36ef8b36f323d29505314f704e21a1a038e2dc387c6409ee0cd24144e187c0f";
            };

            beamDeps = [
              db_connection
              decimal
              jason
            ];
          };
        in
        drv;

      sobelow =
        let
          version = "0.14.0";
          drv = buildMix {
            inherit version;
            name = "sobelow";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "sobelow";
              sha256 = "7ecf91e298acfd9b24f5d761f19e8f6e6ac585b9387fb6301023f1f2cd5eed5f";
            };

            beamDeps = [
              jason
            ];
          };
        in
        drv;

      swoosh =
        let
          version = "1.19.1";
          drv = buildMix {
            inherit version;
            name = "swoosh";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "swoosh";
              sha256 = "eab57462d41a3330e82cb93a9d7640f5c79a85951f3457db25c1eb28fda193a6";
            };

            beamDeps = [
              bandit
              finch
              jason
              mime
              plug
              telemetry
            ];
          };
        in
        drv;

      tailwind =
        let
          version = "0.3.1";
          drv = buildMix {
            inherit version;
            name = "tailwind";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "tailwind";
              sha256 = "98a45febdf4a87bc26682e1171acdedd6317d0919953c353fcd1b4f9f4b676a2";
            };
          };
        in
        drv;

      telemetry =
        let
          version = "1.3.0";
          drv = buildRebar3 {
            inherit version;
            name = "telemetry";

            src = fetchHex {
              inherit version;
              pkg = "telemetry";
              sha256 = "7015fc8919dbe63764f4b4b87a95b7c0996bd539e0d499be6ec9d7f3875b79e6";
            };
          };
        in
        drv;

      telemetry_metrics =
        let
          version = "1.1.0";
          drv = buildMix {
            inherit version;
            name = "telemetry_metrics";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "telemetry_metrics";
              sha256 = "e7b79e8ddfde70adb6db8a6623d1778ec66401f366e9a8f5dd0955c56bc8ce67";
            };

            beamDeps = [
              telemetry
            ];
          };
        in
        drv;

      telemetry_poller =
        let
          version = "1.2.0";
          drv = buildRebar3 {
            inherit version;
            name = "telemetry_poller";

            src = fetchHex {
              inherit version;
              pkg = "telemetry_poller";
              sha256 = "7216e21a6c326eb9aa44328028c34e9fd348fb53667ca837be59d0aa2a0156e8";
            };

            beamDeps = [
              telemetry
            ];
          };
        in
        drv;

      thousand_island =
        let
          version = "1.3.13";
          drv = buildMix {
            inherit version;
            name = "thousand_island";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "thousand_island";
              sha256 = "5a34bdf24ae2f965ddf7ba1a416f3111cfe7df50de8d66f6310e01fc2e80b02a";
            };

            beamDeps = [
              telemetry
            ];
          };
        in
        drv;

      websock =
        let
          version = "0.5.3";
          drv = buildMix {
            inherit version;
            name = "websock";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "websock";
              sha256 = "6105453d7fac22c712ad66fab1d45abdf049868f253cf719b625151460b8b453";
            };
          };
        in
        drv;

      websock_adapter =
        let
          version = "0.5.8";
          drv = buildMix {
            inherit version;
            name = "websock_adapter";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "websock_adapter";
              sha256 = "315b9a1865552212b5f35140ad194e67ce31af45bcee443d4ecb96b5fd3f3782";
            };

            beamDeps = [
              bandit
              plug
              websock
            ];
          };
        in
        drv;

      yamerl =
        let
          version = "0.10.0";
          drv = buildRebar3 {
            inherit version;
            name = "yamerl";

            src = fetchHex {
              inherit version;
              pkg = "yamerl";
              sha256 = "346adb2963f1051dc837a2364e4acf6eb7d80097c0f53cbdc3046ec8ec4b4e6e";
            };
          };
        in
        drv;

      yaml_elixir =
        let
          version = "2.11.0";
          drv = buildMix {
            inherit version;
            name = "yaml_elixir";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "yaml_elixir";
              sha256 = "53cc28357ee7eb952344995787f4bb8cc3cecbf189652236e9b163e8ce1bc242";
            };

            beamDeps = [
              yamerl
            ];
          };
        in
        drv;

    };
in
self
