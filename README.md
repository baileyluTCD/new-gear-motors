# NextGear Motors

Elixir [Phoenix](https://www.phoenixframework.org/) App built and tested via [nix](https://nixos.org/) flakes for `NextGear Motors`.

It should be noted that this repository uses a [CC BY-NC-SA 4.0](https://subjectguides.york.ac.uk/creative-commons/by-nc-sa) [License](./LICENSE.txt), hence non authorised commercial uses are not allowed. However, for much of the nix code an [MIT Licensed version](https://github.com/baileyluTCD/elixir-blueprint) exists which may be used and referenced.

## Releases

Detailed patch notes can be found by reading the releases tab.

## Contributing

All development takes place through [nix](https://nixos.org/) for reproducible builds cross systems.

### Development

The development server for this codebase can be started with `nix run .#mprocs`, which starts the following:

- A live reloading phoenix server for web development
- An incremental unit test runner
- A local Postgres server
- A live reloading documentation server

### Testing

All tests for this repository can be run at once with `nix flake check` which will handle correct sandboxing and creation of temporary databases in which to run the tests.

### Formatting

This repository has a [treefmt-nix](https://github.com/numtide/treefmt-nix) configuration for formatting hence to format the repository one may run `nix fmt`.

The `isFormatted` check ensures in CI that the code for the repository must be formatted
