defmodule ExETo.MixProject do
  use Mix.Project

  @source_url "https://github.com/brycejohnston/ex_eto"
  @version "0.1.0"

  def project do
    [
      app: :ex_eto,
      name: "ExETo",
      version: @version,
      elixir: "~> 1.14",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      package: package(),
      docs: docs(),
      preferred_cli_env: [docs: :docs]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Elixir package for calculating reference / potential evapotranspiration (ETo)"
  end

  defp package() do
    [
      name: "ex_eto",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["MIT"],
      maintainers: ["Bryce Johnston"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "ExETo",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/ex_eto",
      source_url: @source_url,
      extras: ["README.md", "LICENSE.md"]
    ]
  end
end
