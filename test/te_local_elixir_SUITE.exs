defmodule :te_local_elixir_SUITE do
  require Record
  # https://elixirforum.com/t/module-epp-dodger-is-not-available/56185
  # https://elixirforum.com/t/how-to-import-constants-from-erlang-header-file/23901/6
  te =
    :code.lib_dir(:tracing_experiments)++~c"/include/tracing_experiments.hrl" |>
    List.to_string  
  
  with {:ok, forms} <- :epp_dodger.parse_file(te) do
    for {:tree, :attribute, _, {_, {:atom, _, :define}, [{_, _, name}, {_, _, value}]}} <- forms, do:  Application.put_env(__MODULE__, name, value)
  end
  
  
  def all do
    [:switch_test, :five_seconds_test]
  end		

  def init_per_suite(config) do
    ok1 = :application.start(:sasl)
    ok2 = :application.start(:tracing_experiments)
    :ct.pal(~c"************************* applications start ~p", [{ok1, ok2}])
    config
  end

  def end_per_suite(config) do
    ok2 = :application.stop(:tracing_experiments)
    ok1 = :application.stop(:sasl)
    :ct.pal(~c"************************* applications stop ~p", [{ok1,ok2}])
    config
  end
  
  def switch_test(_config) do
    {:ok, state, no} = 
      :gen_statem.call({:global, :tracing_experiments}, :get_value)
    :ct.pal(~c"get state ~p~n",[{state, no}])
  end

  def five_seconds_test(_config) do
    {:ok, :light_state, no} = 
      :gen_statem.call({:global, :tracing_experiments}, :get_value)
    :tracing_experiments.switch_state()
    :timer.sleep(5 * get(:HeavyStateWindowLength))
    {:ok, :heavy_state, _no} =
      :gen_statem.call({:global, :tracing_experiments}, :get_value )
    :tracing_experiments.switch_state()
    newNo = no+6
    {:ok, :light_state, ^newNo} =
      :gen_statem.call({:global, :tracing_experiments}, :get_value)
  end

  defp get(var) do
    Application.get_env(__MODULE__, var)
  end

end



