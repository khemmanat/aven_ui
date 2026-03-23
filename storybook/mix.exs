defmodule Storybook.MixProject do
  use Mix.Project

  def project do
    [
      app: :storybook,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Storybook.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.8"},
      {:phoenix_live_view, "~> 1.1"},
      {:phoenix_html, "~> 4.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:bandit, "~> 1.2"},
      # Point to local AvenUI in dev, hex in prod
      {:aven_ui, path: "../", only: :dev},
      {:aven_ui, "~> 0.2", only: :prod}
    ]
  end
end
