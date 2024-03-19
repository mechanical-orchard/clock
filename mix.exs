defmodule Clock.MixProject do
  use Mix.Project

  def project do
    [
      app: :clock,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      dialyzer: [plt_file: {:no_warn, "tmp/plts/dialyzer.plt"}, plt_add_apps: [:mix, :ex_unit]],
      deps: deps(),
      aliases: aliases()
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
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false}
    ]
  end
end
