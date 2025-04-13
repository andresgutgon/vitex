defmodule Vitex.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :vitex,
      name: "Vitex",
      version: @version,
      elixir: ">= 1.14.0",
      description: description(),
      source_url: links()["GitHub"],
      homepage_url: links()["GitHub"],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      aliases: aliases(),
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"]
    ]
  end

  def application do
    [
      # inets is used by ViteJS ssr adapter to fetch the page on the dev vite server
      extra_applications: [:logger, :inets]
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/andresgutgon/vitex",
      "Readme" => "https://github.com/andresgutgon/vitex/blob/v#{@version}/README.md"
    }
  end

  defp description do
    "ViteJS integration for Phoenix Framework and InertiaJS. It provides a set of helpers to use ViteJS in your Phoenix application."
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md",
        "LICENSE.md"
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Andrés Gutiérrez"],
      licenses: ["MIT"],
      links: links(),
      files:
        ~w(lib priv/vitejs/vitePlugin.js priv/vitejs/vitePlugin.d.ts mix.exs README.md LICENSE.md)
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:phoenix, "~> 1.7"},
      {:phoenix_html, ">= 3.0.0"},
      # {:inertia, "~> 2.4", optional: true},
      {:inertia,
       git: "https://github.com/andresgutgon/inertia-phoenix.git",
       ref: "5c557d36af7082449236bc32ffbda5f49949d0a2"}
    ]
  end

  defp aliases do
    [
      compile: [&copy_js/1, "compile"]
    ]
  end

  defp copy_js(_) do
    source = "assets/js"
    destination = "priv/vitejs"
    File.mkdir_p!(destination)

    Enum.each(["vitePlugin.js", "vitePlugin.d.ts"], fn file ->
      source = Path.join(source, file)
      destination = Path.join(destination, file)
      File.cp!(source, destination)
    end)
  end
end
