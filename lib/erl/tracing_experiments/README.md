tracing_experiments
=====

An OTP application with two state gen_statem made for testing Erlang facilities like .
The light_state is just passive, the heavy_state reiterates the state switch every 1s.
The application keeps the number of state switches as the value that can be returned with call to the statem.

Build
-----
    Install erlang and rebar3 for example with asdf.
    https://github.com/asdf-vm/asdf
    https://github.com/asdf-vm/asdf-erlang
    https://github.com/Stratus3D/asdf-rebar
    
    $ rebar3 compile

Run application in a shell and test call get_value
-----
        
    $ rebar3 as dbg shell
    > tracing_experiments:switch_state().
    ...
    > tracing_experiments:switch_state().
    > gen_statem:call({global, tracing_experiments}, get_value).

Common test without debug info
-----
    
    $ rebar3 as ct ct --sname=my_node
    $ firefox ctlogs/index.html 

Common test with debug info
-----
  
    $ rebar3 as ct_dbg ct --suite te_local_SUITE 
    $ firefox ctlogs/index.html 

Common test with distributed nodes
-----
  
    $ ./dist_ct.sh  
    $ firefox ctlogs/index.html 