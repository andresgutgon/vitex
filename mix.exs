defmodule Vitex.MixProject do
  use Mix.Project

  def project do
    [
      app: :vitex,
      version: "0.1.0",
      elixir: "~> 1.15",
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "ViteJS integration for Phoenix Framework. It provides a set of helpers to use ViteJS in your Phoenix application."
  end

  defp deps do
    [
      # {:inertia, "~> 2.4", optional: true},
      {:inertia,
       git: "https://github.com/andresgutgon/inertia-phoenix.git",
       ref: "64495aeabed79d191dd1384c743e938420384623"}
    ]
  end
end
