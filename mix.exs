defmodule AvenUI.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/khemmanat/aven_ui"

  def project do
    [
      app: :aven_ui,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      name: "AvenUI",
      description: "A free, open-source UI component library for Phoenix LiveView — no paywalls.",
      source_url: @source_url
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:phoenix, "~> 1.8"},
      {:phoenix_live_view, "~> 1.1"},
      {:phoenix_html, "~> 4.3"},
      {:ex_doc, "~> 0.40.1", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Your Name"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib assets priv mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end
end
