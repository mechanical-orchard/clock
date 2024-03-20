defmodule Clock.MixProject do
  use Mix.Project

  def project do
    [
      name: "Clock",
      description: "A simple clock protocol for time traveling in tests.",
      app: :clock,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      dialyzer: [plt_file: {:no_warn, "tmp/plts/dialyzer.plt"}, plt_add_apps: [:mix, :ex_unit]],
      deps: deps(),
      package: package(),
      source_url: "https://github.com/mechanical-orchard/clock",
      aliases: aliases(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      ci: ["credo", "dialyzer", "test"]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Byron Anderson", "Brent Wheeldon"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/mechanical-orchard/clock"
      }
    ]
  end

  defp docs do
    [
      main: "Clock",
      extras: ["README.md"]
    ]
  end
end
