defmodule RandomColor.MixProject do
  use Mix.Project

  def project do
    [
      app: :random_color,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      package: package(),
      source_url: "https://github.com/tylersamples/random_color"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "A utility for generating random colors (an Elixir port of davidmerfield/randomColor)"
  end

  def package do
    [
      name: "random_color",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tylersamples/random_color"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
    ]
  end
end
