defmodule InputTest do
  use ExUnit.Case
  def temp_input_server do
    IO.gets "welcom"
  end

  test "kill input server" do
    pid = spawn(__MODULE__, :temp_input_server, [])
    #pid = Monopoly.Input.generate_input_server(self)
    #pid = spawn(Monopoly.Input, :input_server, [false, self])
    :timer.sleep 1000
    Process.exit(pid, :kill)
    IO.puts ""
    IO.gets "com'n"
    # pid = spawn(__MODULE__, :input_server, [])
    # :timer.sleep 1000
    # Process.exit(pid, :kill)
    # #IO.puts ""
    # IO.gets "com'n"
  end
end
