defmodule CtElixirExperiment.MixProject do
  use Mix.Project

  def project do
    [
      app: :ct_elixir_experiment,
      version: "0.1.0",
      elixir: "~> 1.18-dev",
      erlc_paths: ["lib/erl/src"],
      erlc_include_path: ["lib/erl/include"],      
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end
  # Run "mix help compile.app" to learn about applications.
  def application do
    test_apps =
    if Mix.env() == :test do
      [:common_test, :syntax_tools]
    else
      []
    end      
    [ extra_applications: [:logger, :tracing_experiments]++test_apps ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
    {:tracing_experiments, path: "lib/erl/tracing_experiments"}
    ]
  end
end
