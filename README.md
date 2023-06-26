# ExETo

[![hex.pm](https://img.shields.io/hexpm/v/ex_eto.svg)](https://hex.pm/packages/ex_eto)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_eto/)
[![hex.pm](https://img.shields.io/hexpm/dt/ex_eto.svg)](https://hex.pm/packages/ex_eto)
[![hex.pm](https://img.shields.io/hexpm/l/ex_eto.svg)](https://hex.pm/packages/ex_eto)

Elixir package for calculating reference/potential evapotranspiration (ETo), also referred to as potential evapotranspiration (PET), using the FAO-56 Penman-Monteith method. This is ported from the [Ruby evapotranspiration gem](https://github.com/brycejohnston/evapotranspiration) which is based on the [PyETo Python package from Mark Richards](https://github.com/woodcrafty/PyETo). The package provides numerous methods for estimating missing meteorological data.

Three methods for estimating ETo/PET are implemented:

- FAO-56 Penman-Monteith (Allen et al, 1998)
- Hargreaves (Hargreaves and Samani, 1982; 1985)
- Thornthwaite (Thornthwaite, 1948)

## Installation

The package can be installed by adding `ex_eto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_eto, "~> 0.1.0"}
  ]
end
```

