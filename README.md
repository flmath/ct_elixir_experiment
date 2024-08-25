# CtElixirExperiment
## Introduction
The Erlang Common Test is a robust test system included byt default in OTP.
The Elixir has its own test system, but it is more geared towards unit test and less functional testing of nodes.
However Elixir is more elastic language allowing to easily incorporate more conscise test descriptions.
Since Elixir compiles to Erlang AST we can use the interoperatibility to get the best of two worlds.

In https://github.com/flmath/tracing_experiments I wrote a minimal gen_statem application for testing purpose.
In this repository the application is run with the mix, and the common tests suites are adapted to elixir.

## Execution
They can be run as 

```bash
mix test
```
and if we want to run tests that require named nodes 
```bash
elixir --sname ct -S mix test
```
We can use application from shell:

```bash
$iex -S mix
```

```elixir
iex(1)> :tracing_experiments.get_state
{:ok, :light_state, 0}
iex(2)> :tracing_experiments.switch_state
:ok
iex(3)> :tracing_experiments.get_state
{:ok, :heavy_state, 3}
iex(4)> :tracing_experiments.get_state
{:ok, :heavy_state, 4}
iex(5)> :tracing_experiments.switch_state
:ok
```

## Adaptation process
* create mix project
* add erlang project code to lib
* in mix.exs
**add where erlang code will be stored
```elixir
erlc_paths: ["lib/erl/src"],
erlc_include_path: ["lib/erl/include"],      
```
** the erlang application in dependecies
```elixir
    {:tracing_experiments, path: "lib/erl/tracing_experiments"}
    ```
** necessary for the common test applications
```elixir
    test_apps =
    if Mix.env() == :test do
      [:common_test,
      :syntax_tools # note: https://elixirforum.com/t/module-epp-dodger-is-not-available/56185
      ]
    else
      []
    end      
    [ extra_applications: [:logger, :tracing_experiments]++test_apps ]
```

* use my modified test_helper.exs module
it creates "logs" directory where the commont test logs will be stored.
Since Elixir is compiled to Erlang AST and we never get Erlang code in the process we need to set {:auto_compile,false} and compile suites from exs files ourselves.

* Adapt modules
** name of the module should be atom that ends with "_SUITE", becasue x_SUITE module is compiled to x_SUITE.beam.
Actual file name does not matter for Elixir compiler, but it should end " _SUITE.exs" for test_helper functions.
The x_SUITE is picked up by ct application then.
** Loading hrl files is a little bit tricky I copy paste method from:
https://elixirforum.com/t/how-to-import-constants-from-erlang-header-file/23901/6
and put results into the application environment variables.
```elixir
   te =
     :code.lib_dir(:tracing_experiments)++~c"/include/tracing_experiments.hrl" |>
     List.to_string  
  
   with {:ok, forms} <- :epp_dodger.parse_file(te) do
     for {:tree, :attribute, _, {_, {:atom, _, :define}, [{_, _, name}, {_, _, value}]}} <- forms, do:  Application.put_env(__MODULE__, name, value)
   end
```
** We need to map  init_per_suite/1, end_per_suite/1 and all/0 functions for ct to work properly
** It is good to add " unless Node.alive? do" control for distributed nodes.
** Most of common test string are Erlang strings which means they are lists of characters not binaries:
```elixir
:ct.pal(~c"pong == ~p",[ :pong = :net_adm.ping(hostNode)])
```