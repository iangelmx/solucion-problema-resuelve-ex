defmodule Resuelve.PruebasTest do
  alias Resuelve.Helpers.JugadorHelper
  alias Resuelve.Context.Jugador
  use ExUnit.Case

  doctest Resuelve.Helpers.JugadorHelper

  test "build a %Jugador{} from map JSON" do
    assert JugadorHelper.jugador_builder(
      %{"nombre" => "Ramíro",
        "nivel" => nil,
        "goles" => -5,
        "sueldo" => "10",
        "bono" => -10,
        "sueldo_completo" => "hey",
        "equipo" => "nuevo" } ) == %Jugador{
                                    nombre: "Ramíro",
                                    nivel: nil,
                                    goles: -5,
                                    sueldo: "10",
                                    bono: -10,
                                    sueldo_completo: "hey",
                                    equipo: "nuevo",
                                  }
  end

  test "get the level of a player" do

    assert JugadorHelper.get_level(  )
  end

end
