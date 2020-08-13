defmodule Resuelve.Contexts.PruebasFirst do
  use ExUnit.Case
  doctest Resuelve.Contexts.PruebasFirst

  test  do
    assert Resuelve.Contexts.PruebasFirst.hello() == :world
  end
end
