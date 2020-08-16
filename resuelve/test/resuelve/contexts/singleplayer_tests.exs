Ecto.Adapters.SQL.Sandbox.mode(Resuelve.Repo, {:shared, self()})

defmodule Resuelve.SingleplayerTests do
  alias Resuelve.Helpers.JugadorHelper
  alias Resuelve.Context.Jugador

  use ExUnit.Case, async: true
  # use Resuelve.ConnCase

  doctest Resuelve.Helpers.JugadorHelper

  test "build a %Jugador{} from map JSON" do
    assert JugadorHelper.jugador_builder(%{
             "nombre" => "Ramíro",
             "nivel" => nil,
             "goles" => -5,
             "sueldo" => "10",
             "bono" => -10,
             "sueldo_completo" => "hey",
             "equipo" => "nuevo"
           }) == %Jugador{
             nombre: "Ramíro",
             nivel: nil,
             goles: -5,
             sueldo: "10",
             bono: -10,
             sueldo_completo: "hey",
             equipo: "nuevo"
           }
  end

  test "getting the level of a player when nivel is nil" do
    to_test = %Jugador{nivel: nil}
    assert JugadorHelper.get_level(to_test) == nil
  end

  test "getting the level of a player when nivel is ''" do
    to_test = %Jugador{nivel: ""}
    assert JugadorHelper.get_level(to_test) == ""
  end

  test "getting the level of a player when nivel is 'B'" do
    to_test = %Jugador{nivel: "B"}
    assert JugadorHelper.get_level(to_test) == "B"
  end

  test "getting the level of a player when nivel is 'azfawer4A983Dadfa5\"43/afs54fas.'" do
    to_test = %Jugador{nivel: "azfawer4A983Dadfa5\"43/afs54fas"}
    assert JugadorHelper.get_level(to_test) == "azfawer4A983Dadfa5\"43/afs54fas"
  end

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Resuelve.Repo)
    # Setting the shared mode must be done only after checkout
    Ecto.Adapters.SQL.Sandbox.mode(Resuelve.Repo, {:shared, self()})
  end

  test "Getting the goal goals of the level 'A'" do
    level = "A"
    assert JugadorHelper.get_level_goal_goals(level) == 5
  end

  test "Getting the goal goals of the level 'Abcdafe6E' non-existent" do
    level = "Abcdafe6E"
    assert JugadorHelper.get_level_goal_goals(level) == nil
  end

  test "Getting the goal goals of the level '' non-existent" do
    level = ""
    assert JugadorHelper.get_level_goal_goals(level) == nil
  end

  test "Adding the goles_minimos key value to a player of level B" do
    input = %Jugador{nivel: "B"}
    simulation = %Jugador{nivel: "B", goles_minimos: 10}
    assert JugadorHelper.get_player_goals_goal(input) == simulation
  end

  test "Adding the goles_minimos key value to a player of level 'Abcdafe6E' non-existent" do
    input = %Jugador{nivel: "Abcdafe6E"}
    simulation = %Jugador{nivel: "Abcdafe6E", goles_minimos: nil}
    assert JugadorHelper.get_player_goals_goal(input) == simulation
  end

  test "Adding the goles_minimos key value to a player of level '' non-existent" do
    input = %Jugador{nivel: ""}
    simulation = %Jugador{nivel: "", goles_minimos: 0}
    assert JugadorHelper.get_player_goals_goal(input) == simulation
  end

  test "Getting the single compliance of a player with more goals than goals goal" do
    input = %Jugador{goles_minimos: 5, goles: 6}
    assert JugadorHelper.calculate_single_compliance(input) == 100.0
  end

  test "Getting the single compliance of a player with less goals than goals goal" do
    input = %Jugador{goles_minimos: 10, goles: 6}
    assert JugadorHelper.calculate_single_compliance(input) == 60.0
  end

  test "Getting the single compliance of a player with no data of scored goals" do
    input = %Jugador{goles_minimos: 5, goles: nil}
    assert JugadorHelper.calculate_single_compliance(input) == nil
  end

  test "Getting the single compliance of a player with no data of goals goal" do
    input = %Jugador{goles_minimos: nil, goles: 10}
    assert JugadorHelper.calculate_single_compliance(input) == nil
  end

  test "Adding the alcance_ind key value to a single player" do
    input = %Jugador{goles_minimos: 10, goles: 10}
    simulation_res = %Jugador{goles_minimos: 10, goles: 10, alcance_ind: 100.0}
    assert JugadorHelper.get_single_compliance(input) == simulation_res
  end

  test "Adding the alcance_ind key value to a single player with no data of scored goals" do
    input = %Jugador{goles_minimos: 10, goles: nil}
    simulation_res = %Jugador{goles_minimos: 10, goles: nil, alcance_ind: nil}
    assert JugadorHelper.get_single_compliance(input) == simulation_res
  end

  test "Adding the alcance_ind key value to a single player with no data of goals goal" do
    input = %Jugador{goles_minimos: nil, goles: 10_000_000_000_000_000_000}

    simulation_res = %Jugador{
      goles_minimos: nil,
      goles: 10_000_000_000_000_000_000,
      alcance_ind: nil
    }

    assert JugadorHelper.get_single_compliance(input) == simulation_res
  end

  test "Getting the global compliance of a player with team and single compliances" do
    input = %Jugador{alcance_team: 100.0, alcance_ind: 100.0}
    simulation_res = 100.0
    assert JugadorHelper.get_global_compliance(input) == simulation_res
  end

  test "Getting the global compliance of a player" do
    input = %Jugador{alcance_team: 66.7, alcance_ind: 88.5}
    simulation_res = 77.6
    assert JugadorHelper.get_global_compliance(input) == simulation_res
  end

  test "Getting the global compliance of a player with no team compliance" do
    input = %Jugador{alcance_team: nil, alcance_ind: 88.5}
    simulation_res = nil
    assert JugadorHelper.get_global_compliance(input) == simulation_res
  end

  test "Getting the global compliance of a player with no team either single compliances" do
    input = %Jugador{alcance_team: nil, alcance_ind: nil}
    simulation_res = nil
    assert JugadorHelper.get_global_compliance(input) == simulation_res
  end

  test "Getting the bonus part for a single player" do
    input = %Jugador{bono: 5000, alcance_ind: 100, alcance_team: 100}
    simulation_res = 2525.0
    assert JugadorHelper.calculate_bonus_part(50.5, input) == simulation_res
  end

  test "Getting the bonus part for a single player with no global complince" do
    input = %Jugador{bono: 5000, alcance_ind: 100, alcance_team: 100}
    simulation_res = nil
    assert JugadorHelper.calculate_bonus_part(nil, input) == simulation_res
  end

  test "Getting the complete salary for a single player" do
    input = %Jugador{bono: 5000, sueldo: 10000, alcance_ind: 100, alcance_team: 100}
    simulation_res = 15000
    assert JugadorHelper.calculate_salary(input) == simulation_res
  end

  test "Getting the complete salary for a single player with no bonus" do
    input = %Jugador{bono: nil, sueldo: 10000, alcance_ind: 100, alcance_team: 100}
    simulation_res = 10000
    assert JugadorHelper.calculate_salary(input) == simulation_res
  end

  test "Getting the complete salary for a single player with no salary" do
    input = %Jugador{bono: 7000, sueldo: nil, alcance_ind: 100, alcance_team: 100}
    simulation_res = nil
    assert JugadorHelper.calculate_salary(input) == simulation_res
  end

  test "Getting the complete salary for a single player with negative bonus" do
    input = %Jugador{bono: -5904, sueldo: 10000, alcance_ind: 100, alcance_team: 100}
    simulation_res = 10000
    assert JugadorHelper.calculate_salary(input) == simulation_res
  end

  test "Getting the complete salary for a single player with negative salary" do
    input = %Jugador{bono: 5980, sueldo: -4_198_048, alcance_ind: 100, alcance_team: 100}
    simulation_res = 10000
    # quit nil
    assert JugadorHelper.calculate_salary(input) == nil
  end

  test "Getting the complete salary for a list of players with different characteristics" do
    input = [
      %Jugador{bono: 5980, sueldo: -4_198_048, alcance_ind: nil, alcance_team: 100},
      %Jugador{bono: 5000, sueldo: 10000, alcance_ind: 93.33, alcance_team: 100},
      %Jugador{bono: -41981, sueldo: 12_651_650_849_804, alcance_ind: 100, alcance_team: 59.5}
    ]

    simulation_res = [
      %Jugador{
        bono: 5980,
        sueldo: -4_198_048,
        alcance_ind: nil,
        alcance_team: 100,
        sueldo_completo: nil,
        failed: true
      },
      %Jugador{
        bono: 5000,
        sueldo: 10000,
        alcance_ind: 93.33,
        alcance_team: 100,
        sueldo_completo: 14833.25,
        failed: false
      },
      %Jugador{
        bono: -41981,
        sueldo: 12_651_650_849_804,
        alcance_ind: 100,
        alcance_team: 59.5,
        sueldo_completo: 12_651_650_849_804,
        failed: false
      }
    ]

    assert JugadorHelper.calculate_final_salary_players(input) == simulation_res
  end
end
