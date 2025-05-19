{
  pkgs,
  flake,
  system,
  ...
}:
let
  mixNixDeps = pkgs.callPackages ../../deps.nix { };
in
pkgs.beamPackages.mixRelease {
  inherit mixNixDeps;

  pname = "is-formatted";
  version = flake.lib.readMixVersion ../../mix.exs;

  src = flake;

  DATABASE_URL = "";
  SECRET_KEY_BASE = "";

  nativeBuildInputs = [
    flake.packages.${system}.appDependencies
    flake.lib.${system}.treefmt.config.build.wrapper
  ];

  doCheck = true;

  preCheck = ''
    export HOME=$TMPDIR
    cat > $HOME/.gitconfig <<EOF
    [user]
      name = Nix
      email = nix@localhost
    [init]
      defaultBranch = main
    EOF
  '';

  checkPhase = ''
    runHook preCheck

    git init --quiet
    git add .
    git commit -m init --quiet

    treefmt --no-cache

    trap 'echo "Try running \"nix fmt\" to correct the formatting error."' ERR

    git status --short
    git --no-pager diff --exit-code
  '';
}
