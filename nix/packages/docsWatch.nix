{ pkgs, flake }:
pkgs.writeShellApplication {
  name = "docsWatch";

  runtimeInputs = with pkgs; [
    watchexec
    elixir
    nodePackages.browser-sync
  ];

  text = ''
    echo "Starting dev server for elixir documentation..."

    browser-sync start --server ./doc &

    watchexec -e ex,exs,heex,md mix docs
  '';
}
