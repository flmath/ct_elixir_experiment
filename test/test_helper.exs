File.mkdir_p("logs")
IEx.Helpers.cd("test")
{:ok, filesnames} = File.ls()

for filename <- filesnames, String.match?(filename, ~r"_SUITE\.exs$") do
    IEx.Helpers.c(filename, ".")
end

IEx.Helpers.cd("..")
:ct.run_test([{:auto_compile,false}, {:logdir, ~c"logs"} ])

ok = File.rm_rf(Path.wildcard("test/*beam"))
IO.puts("removed files #{inspect(ok)}")

