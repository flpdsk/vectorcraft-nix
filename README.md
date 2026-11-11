# VectorCraft Nix package

This flake packages the upstream VectorCraft desktop app for `x86_64-linux`.
It follows the upstream repository through `vectorcraft-src` and pins the
source revision in `flake.lock`.

## Build locally

```sh
nix build .#vectorcraft
./result/bin/vectorcraft
```

## Publish to Cachix

The `Build VectorCraft cache` workflow runs on relevant pushes and can also be
started manually from GitHub Actions. It updates the upstream source pin,
refreshes the Cargo vendor hash if dependencies changed, builds VectorCraft,
pushes the output to the `flpdsk-vectorcraft` Cachix cache, and only then
commits the new `flake.lock` and hash. A failed build leaves the committed pin
unchanged.
The workflow summary reports the package and runtime closure NAR sizes. Cachix
skips paths already available from `cache.nixos.org`, so the actual cache usage
increase is lower than or equal to the full closure size.

Add a repository secret named `CACHIX_AUTH_TOKEN` with a Cachix write token.
The NixOS configuration must trust the public key for `flpdsk-vectorcraft` and
list `https://flpdsk-vectorcraft.cachix.org` as a substituter.

After the workflow succeeds, update the `vectorcraft-nix` input in the NixOS
flake. That makes NixOS consume the exact package revision the workflow built
and cached.

## Use from NixOS

Add this repository as an input in `/etc/nixos/flake.nix`:

```nix
vectorcraft-nix.url = "github:flpdsk/vectorcraft-nix";
```

Expose it from the package overlay:

```nix
(final: prev: {
  vectorcraft = inputs.vectorcraft-nix.packages.${system}.vectorcraft;
})
```

Then add `vectorcraft` to `environment.systemPackages` in a NixOS module.
