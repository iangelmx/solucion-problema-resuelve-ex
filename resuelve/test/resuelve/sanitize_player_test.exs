defmodule Resuelve.SanitizePlayerHelperTest do
  use Resuelve.DataCase
  alias Resuelve.SourcesTest.Sanitize

  alias Resuelve.Helpers.SanitizePlayerHelper

  test "Getting the missing intereset keys of player map" do
    # When the player keys unimportant keys
    input = %{"nombre" => "ASñafoiejfa31854dfa69", "edad" => 26, "signo_zodiaco" => "Tauro"}
    simulation_output = ["nivel", "goles", "sueldo", "bono", "equipo"]
    assert SanitizePlayerHelper.get_missing_keys_for_player(input) == simulation_output

    # When the player has some but not all required keys
    input = %{
      "nombre" => "ALDKFJ_asf092k3",
      "edad" => 59,
      "nivel" => "A",
      "bono" => 351_870_487.4910,
      "equipo" => "aoi3fj2 3 fwae"
    }

    simulation_output_2 = ["goles", "sueldo"]
    assert SanitizePlayerHelper.get_missing_keys_for_player(input) == simulation_output_2

    # When the player has some but not all required keys
    input = %{
      "nombre" => 6_810_980_980,
      "edad" => 59,
      "nivel" => "A",
      "sueldo" => 351_870_487.4910,
      "goles" => "aoi3fj2 3 fwae"
    }

    simulation_output_3 = ["bono", "equipo"]
    assert SanitizePlayerHelper.get_missing_keys_for_player(input) == simulation_output_3

    # When the player has all the required keys
    input = %{
      "nivel" => "A",
      "bono" => "sdfa94se",
      "equipo" => "aoi3fj2 3 fwae",
      "sueldo" => -18_018_650,
      "goles" => nil
    }

    simulation_output_4 = []

    assert SanitizePlayerHelper.get_missing_keys_for_player(input) == simulation_output_4
  end

  test "Joining elements of list" do
    input = ["A", "B", "C", "bono", "sueldo", "equipo"]
    simulation_output = "A, B, C, bono, sueldo, equipo"
    assert SanitizePlayerHelper.join_list(input) == simulation_output
  end

  test "Checking that player map has the required keys" do
    # When the player has some but not all required keys
    input = %{
      "nombre" => "ALDKFJ_asf092k3",
      "edad" => 59,
      "nivel" => "A",
      "bono" => 351_870_487.4910,
      "equipo" => "aoi3fj2 3 fwae"
    }

    simulation_output_1 = %{
      status: :error,
      info:
        "No se puede calcular el sueldo de \"#{input["nombre"]}\" si le faltan los valores de: goles, sueldo",
      data: input
    }

    assert SanitizePlayerHelper.check_necessary_attrs(input) == simulation_output_1

    # When the player does not have any of the required keys
    input = %{
      "edad" => 59
    }

    simulation_output = %{
      status: :error,
      info:
        "No se puede calcular el sueldo de \"#{input["nombre"]}\" si le faltan los valores de: nivel, goles, sueldo, bono, equipo",
      data: input
    }

    assert SanitizePlayerHelper.check_necessary_attrs(input) == simulation_output
  end

  test "Getting the missing keys of a players group" do
    # When every maps in input does not have any of the required keys
    e_0 = %{
      "nombre" => "ALDKFJ_asf092k3",
      "edad" => 59,
      "nivel" => "A",
      "bono" => 351_870_487.4910,
      "equipo" => "aoi3fj2 3 fwae"
    }

    e_1 = %{
      "edad" => 591
    }

    input = [e_0, e_1]

    simuluation_output = %{
      error: [
        %{
          status: :error,
          info:
            "No se puede calcular el sueldo de \"ALDKFJ_asf092k3\" si le faltan los valores de: goles, sueldo",
          data: e_0
        },
        %{
          status: :error,
          info:
            "No se puede calcular el sueldo de \"\" si le faltan los valores de: nivel, goles, sueldo, bono, equipo",
          data: e_1
        }
      ]
    }

    assert SanitizePlayerHelper.get_missing_keys_in_players(input) == simuluation_output

    # When every maps at the input has the required keys
    e_0 = %{
      "nombre" => "ALsf09SEF352k3",
      "nivel" => "A",
      "bono" => 351_870_487.4910,
      "equipo" => "aoi3fj2 3 fwae",
      "sueldo" => "fas8391",
      "goles" => 5691
    }

    e_1 = %{
      "nombre" => "af8731f3",
      "nivel" => 981,
      "bono" => 989_891.4910,
      "equipo" => "a81",
      "sueldo" => 4598,
      "goles" => 5691
    }

    e_2 = %{
      "nombre" => 5_198_719,
      "nivel" => 98719,
      "bono" => "asfde391",
      "equipo" => "981",
      "sueldo" => "af3 ro2i3m wa",
      "goles" => "6as1f9a81e98a1e9f8ae8f19"
    }

    input = [e_0, e_1, e_2]

    simulation_input = %{
      ok: [%{status: :ok, data: e_0}, %{status: :ok, data: e_1}, %{status: :ok, data: e_2}]
    }

    assert SanitizePlayerHelper.get_missing_keys_in_players(input) == simulation_input

    # When some of the players have all the required keys and some does not
    e_0 = %{
      "nombre" => "6af19",
      "nivel" => "B",
      "bono" => 878.4910,
      "equipo" => 68_519_898,
      "sueldo" => 681_987_987,
      "goles" => 56
    }

    e_1 = %{
      "nombre" => 8_519_898,
      "nivel" => "!af3",
      "bono" => "a33fsdf",
      "equipo" => "a81"
    }

    e_2 = %{
      "nombre" => "81987f9719",
      "nivel" => "6a1f9es8f",
      "bono" => "asfde391",
      "equipo" => "981",
      "sueldo" => "af3 ro2i3m wa",
      "goles" => "6as1f9a81e98a1e9f8ae8f19"
    }

    input = [e_0, e_1, e_2]

    simulation_input = %{
      ok: [%{status: :ok, data: e_0}, %{status: :ok, data: e_2}],
      error: [
        %{
          status: :error,
          info:
            "No se puede calcular el sueldo de \"8519898\" si le faltan los valores de: goles, sueldo",
          data: e_1
        }
      ]
    }

    assert SanitizePlayerHelper.get_missing_keys_in_players(input) == simulation_input
  end

  test "Grouping players with and without errors" do
    # When some of the players have all the required keys and some does not
    input = Sanitize.get_input_check_attrs_player_1()
    simulation_output = Sanitize.get_output_check_attrs_player_1()
    assert SanitizePlayerHelper.check_attrs_players(input) == simulation_output

    # When every players have the required keys
    input = Sanitize.get_input_check_attrs_player_2()
    simulation_output = Sanitize.get_output_check_attrs_player_2()
    assert SanitizePlayerHelper.check_attrs_players(input) == simulation_output
  end

  # After filtering all players that have errors, we can check if the goods have
  # the correct types for processing

  test "Testing if values of map are the expected" do
    # When a player has all the required keys in map, but with unexpected values
    input = %{
      "nombre" => "6af19_1",
      "nivel" => "B",
      "bono" => 878.4910,
      "equipo" => 68_519_898,
      "sueldo" => 96_541_981,
      "goles" => 56
    }

    simulation_output = %{
      status: "failed",
      error: "El jugador #{input["nombre"]} tiene valores inválidos para calcular su sueldo: 'equipo' debería ser una cadena de caracteres"
    }

    assert SanitizePlayerHelper.valid_values(input) == simulation_output

    input = %{
      "nombre" => "6af19_2",
      "nivel" => 159,
      "bono" => 878.4910,
      "equipo" => "Rojo",
      "sueldo" => 96_541_981,
      "goles" => 56
    }

    simulation_output = %{
      status: "failed",
      error: "El jugador #{input["nombre"]} tiene valores inválidos para calcular su sueldo: 'nivel' debería ser una cadena de caracteres"
    }
    assert SanitizePlayerHelper.valid_values(input) == simulation_output

    # When a player has all the required keys and its values are the expected

    input = %{
      "nivel" => "Abc",
      "bono" => 878.4910,
      "equipo" => "Rojo",
      "sueldo" => 96_541_981,
      "goles" => 56
    }

    simulation_output = %{
      status: "ok",
      nombre: input["nombre"],
      goles: 56,
      sueldo: 96_541_981,
      bono: 878.4910,
      equipo: "Rojo",
      nivel: "Abc"
    }

    assert SanitizePlayerHelper.valid_values(input) == simulation_output
  end

  test "Checking of a player group has the expected type in its values" do
    # When some of the players have unexpected type-values
    input = Sanitize.get_input_have_correct_values_1?()
    simulation_output = Sanitize.get_output_have_correct_values_1?()

    assert SanitizePlayerHelper.have_correct_values?(input) == simulation_output

    # When all of the players have unexpected type-values
    input = Sanitize.get_input_have_correct_values_2?()
    simulation_output = Sanitize.get_output_have_correct_values_2?()

    assert SanitizePlayerHelper.have_correct_values?(input) == simulation_output

    # When all of the players have the expected type-values
    input = Sanitize.get_input_have_correct_values_3?()
    simulation_output = Sanitize.get_output_have_correct_values_3?()

    assert SanitizePlayerHelper.have_correct_values?(input) == simulation_output
  end

  test "Taking away the players with error that cannot be processed" do
    # When Some of the players have all the required keys but with unexpected type-values
    input = Sanitize.get_input_have_correct_values_1?()

    simulation_output = %{
      ok: [
        %{
          status: "ok",
          nombre: nil,
          goles: 56,
          sueldo: 96_541_981,
          bono: 878.4910,
          equipo: "Rojo",
          nivel: "Abc"
        }
      ],
      errors: [
        %{
          status: "failed",
          error: "El jugador 6af19 tiene valores inválidos para calcular su sueldo: 'equipo' debería ser una cadena de caracteres"
        },
        %{
          status: "failed",
          error: "El jugador 8319f1af9 tiene valores inválidos para calcular su sueldo: 'nivel' debería ser una cadena de caracteres"
        }
      ]
    }

    assert SanitizePlayerHelper.sanitize_raw_player(input) == simulation_output

    # When some players does not have all of the required keys and have unexpected
    # types-values

    input = Sanitize.get_input_check_attrs_player_1()

    simulation_output = %{
      ok: nil,
      errors: %{
        invalid_values: [
          %{
            status: "failed",
            error: "El jugador  tiene valores inválidos para calcular su sueldo: 'nivel' debería ser una cadena de caracteres"
          },
          %{
            status: "failed",
            error: "El jugador  tiene valores inválidos para calcular su sueldo: 'nivel' debería ser una cadena de caracteres"
          }
        ],
        missing_attributes: [
          %{
            status: :error,
            info:
              "No se puede calcular el sueldo de \"8519898\" si le faltan los valores de: goles, sueldo",
            data: %{
              "nombre" => 8_519_898,
              "nivel" => "!af3",
              "bono" => "a33fsdf",
              "equipo" => "a81"
            }
          }
        ]
      }
    }

    assert SanitizePlayerHelper.sanitize_raw_player(input) == simulation_output
  end
end
