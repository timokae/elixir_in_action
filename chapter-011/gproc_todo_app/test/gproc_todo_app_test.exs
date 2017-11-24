defmodule GprocTodoAppTest do
  use ExUnit.Case
  doctest GprocTodoApp

  test "greets the world" do
    assert GprocTodoApp.hello() == :world
  end
end
