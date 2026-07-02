# enterprise-kernloom-policies

`enterprise-kernloom-policies` contains human-authored `*.intent.kni` files, policy PR state, simulation examples and generated review/artifact outputs.

## Build

No binary build is required for Slice 0.

## Test

```sh
make validate
```

## Release

Policy promotion must run KNI lint, compile, meaning coverage, simulation, validation, manifest generation, artifact generation and PR status checks.

## Dependencies

KNI values resolve against `kernloom-core-registry` and `enterprise-kernloom-registry`.

## Related Repos

Forge in `kernloom-core` compiles policies from this repository. Generated files under `generated/` are normally produced by Forge, not edited by hand.

