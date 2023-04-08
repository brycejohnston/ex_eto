# ExETo

Elixir package for calculating reference/potential evapotranspiration (ETo), also referred to as potential evapotranspiration (PET), using the FAO-56 Penman-Monteith method. This was originally ported into Ruby from the [PyETo Python package from Mark Richards](https://github.com/woodcrafty/PyETo). The package provides numerous methods for estimating missing meteorological data.

Three methods for estimating ETo/PET are implemented:

FAO-56 Penman-Monteith (Allen et al, 1998)
Hargreaves (Hargreaves and Samani, 1982; 1985)
Thornthwaite (Thornthwaite, 1948)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_eto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_eto, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_eto>.

