defmodule CommerceCure.Mixfile do
  use Mix.Project

  @version "0.0.2"

  def project do
    [
      app: :commerce_cure,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:countries, "~> 1.4"},
      {:money, "~> 1.2"},
      {:poison, "~> 3.1"},
      {:sweet_xml, "~> 0.6"},
      {:xml_builder, "~> 0.1"},
      {:tesla, "~> 0.9"},
      {:hackney, "~> 1.9"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
    ]
  end
end
