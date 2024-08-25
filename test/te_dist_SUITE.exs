defmodule :te_dist_SUITE do
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
     unless Node.alive? do
       :ct.pal(~c"************************* this suite works only for named nodes")
       :skip
       else
       {:ok, hostNodeA} = start_slave(:a)
       :ct.pal(~c"************************* applications start ~p", [{hostNodeA}])
       :ok = :global.sync()
       config
     end
   end


def start_slave(node) do 
   # appPath = ~c"../../_build/dist+test/lib/tracing_experiments/ebin"
    {:ok, _Sref,hostNode} = :peer.start(%{:name => node})
    :pong = :net_adm.ping(hostNode)
    :ct.pal(~c"pong == ~p",[ :net_adm.ping(hostNode)])
  #  ok = :erpc.call(hostNode, :code,:add_patha,[appPath])
    :erpc.call(hostNode, :application, :start, [:sasl])
   # ok2 = :erpc.call(hostNode, :application, :start, [:tracing_experiments])
   # :ct.pal(~c"erpc ~p",[{ok,ok2}])
    {:ok, hostNode}
    end

  def end_per_suite(config) do
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
  
