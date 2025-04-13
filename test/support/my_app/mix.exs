defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixirc_paths: ["lib"],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {MyApp.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_html, ">= 3.0.0"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_view, "~> 1.0"}
    ]
  end
end
