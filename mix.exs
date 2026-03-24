defmodule AvenUI.MixProject do
  use Mix.Project

  @version "0.2.2"
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
      description:
        "21 accessible Phoenix LiveView components. Requires Tailwind v4 + Phoenix 1.8. Dark mode, shadcn-style installer. Free forever, MIT licensed.",
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
      maintainers: ["Khemmanat"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib assets mix.exs README.md LICENSE CHANGELOG.md)
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
