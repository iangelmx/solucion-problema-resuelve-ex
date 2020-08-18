defmodule Resuelve.PlayerHelperTest do
  use Resuelve.DataCase

  alias Resuelve.Helpers.PlayerHelper

  test "Getting the minimum goals according the level and team" do
    # When it is not stipulated the team, it assumes is Resuelve FC
    # When all the levels are registered
    input_p = [%{nivel: "B"}, %{nivel: "A"}, %{nivel: "A"}, %{nivel: "Cuauh"}, %{nivel: "C"}]
    input_t = nil

    simulation_output = [
      %{ nivel: "B", goles_minimos: 10 },
      %{ nivel: "A", goles_minimos: 5 },
      %{ nivel: "A", goles_minimos: 5 },
      %{ nivel: "Cuauh", goles_minimos: 20 },
      %{ nivel: "C", goles_minimos: 15 }
    ]

    assert PlayerHelper.get_minimum_player_goals(input_p, input_t) == simulation_output

    # When it is not stipulated the team, it assumes is Resuelve FC
    # When some of the levels are not registered
    input_p = [
      %{nivel: "Bardo"},
      %{nivel: "A"},
      %{nivel: "Asno"},
      %{nivel: "71891"},
      %{nivel: "C"}
    ]

    input_t = nil

    simulation_output = [
      {:error, "Nivel no registrado para jugador "},
      %{
        nivel: "A",
        goles_minimos: 5
      },
      {:error, "Nivel no registrado para jugador "},
      {:error, "Nivel no registrado para jugador "},
      %{
        nivel: "C",
        goles_minimos: 15
      }
    ]

    assert PlayerHelper.get_minimum_player_goals(input_p, input_t) == simulation_output

    # When team is different of Resuelve FC and not nil
    # When all of the levels are registered
    input_p = [
      %{nivel: "A1"},
      %{nivel: "A2"},
      %{nivel: "A1"},
      %{nivel: "A1"},
      %{nivel: "A2"}
    ]

    input_t = "Test FC"

    simulation_output = [
      %{nivel: "A1", goles_minimos: 10},
      %{nivel: "A2", goles_minimos: 20},
      %{nivel: "A1", goles_minimos: 10},
      %{nivel: "A1", goles_minimos: 10},
      %{nivel: "A2", goles_minimos: 20}
    ]

    assert PlayerHelper.get_minimum_player_goals(input_p, input_t) == simulation_output

    # When team is different of Resuelve FC, registered and not nil
    # When some levels are not registered
    input_p = [
      %{nivel: "A1"},
      %{nivel: "B1"},
      %{nivel: "B2"},
      %{nivel: "C1"},
      %{nivel: "A2"}
    ]

    input_t = "Test FC"

    simulation_output = [
      %{nivel: "A1", goles_minimos: 10},
      {:error, "Nivel no registrado en el equipo #{input_t} para jugador "},
      {:error, "Nivel no registrado en el equipo #{input_t} para jugador "},
      {:error, "Nivel no registrado en el equipo #{input_t} para jugador "},
      %{nivel: "A2", goles_minimos: 20}
    ]

    assert PlayerHelper.get_minimum_player_goals(input_p, input_t) == simulation_output

    # When team is different of Resuelve FC and its not registered and not nil
    # When some levels are not registered
    input_p = [
      %{nivel: "A1ASF6E"},
      %{nivel: "B1238"},
      %{nivel: "B2A38"},
      %{nivel: "C1"},
      %{nivel: "A2A381C /2 1"}
    ]

    input_t = "EL mejor FC"

    simulation_output = [
      {:error, "Nivel no registrado en el equipo #{input_t} para jugador "},
      {:error, "Nivel no registrado en el equipo #{input_t} para jugador "},
      {:error, "Nivel no registrado en el equipo #{input_t} para jugador "},
      {:error, "Nivel no registrado en el equipo #{input_t} para jugador "},
      {:error, "Nivel no registrado en el equipo #{input_t} para jugador "}
    ]

    assert PlayerHelper.get_minimum_player_goals(input_p, input_t) == simulation_output
  end

  test "Calculating the individual compliance of a player" do
    # When goles and goles_minimos are positives
    input = %{goles: 120_904_984, goles_minimos: 980_498_409_841}
    simulation_output = 120_904_984 * 100 / 980_498_409_841
    assert PlayerHelper.calculate_individual_compliance_player(input) == simulation_output

    # When goles or goles minimos are negatives
    input = %{goles: -120_904_984, goles_minimos: 980_498_409_841}
    simulation_output = 0
    assert PlayerHelper.calculate_individual_compliance_player(input) == simulation_output

    input = %{goles: 650_984, goles_minimos: -980_498_409_841}
    simulation_output = 0
    assert PlayerHelper.calculate_individual_compliance_player(input) == simulation_output

    # When goles or goles minimos are nil
    input = %{goles: nil, goles_minimos: 980_498_409_841}
    simulation_output = 0
    assert PlayerHelper.calculate_individual_compliance_player(input) == simulation_output
  end

  test "Getting the minimum goals and separating the failed players" do
    # When some of the players have unregistered levels at Resuelve FC
    input_p = [%{nivel: "B"}, %{nivel: "As"}, %{nivel: "A"}, %{nivel: "Cuauh"}, %{nivel: "C1"}]
    input_t = nil

    simulation_output = %{
      players: [
        %{ nivel: "B", goles_minimos: 10 },
        %{ nivel: "A", goles_minimos: 5 },
        %{ nivel: "Cuauh", goles_minimos: 20 }
      ],
      error: [
        { :error,  "Nivel no registrado para jugador " },
        { :error,  "Nivel no registrado para jugador " }
      ]
    }
    assert PlayerHelper.get_minimum_player_goals_and_separate(input_p, input_t) == simulation_output

    # When some of the players have registered levels at Resuelve FC
    input_p = [%{nivel: "B"}, %{nivel: "A"}, %{nivel: "Cuauh"}]
    input_t = nil

    simulation_output = %{
      players: [
        %{ nivel: "B", goles_minimos: 10 },
        %{ nivel: "A", goles_minimos: 5 },
        %{ nivel: "Cuauh", goles_minimos: 20 }
      ]
    }
    assert PlayerHelper.get_minimum_player_goals_and_separate(input_p, input_t) == simulation_output

    # When all the players have unregistered levels at Resuelve FC or other teams
    input_p = [%{nivel: "Ba"}, %{nivel: "Ae"}, %{nivel: "E15"}]
    input_t = nil

    simulation_output = %{
      error: [
        { :error,  "Nivel no registrado para jugador " },
        { :error,  "Nivel no registrado para jugador " },
        { :error,  "Nivel no registrado para jugador " }
      ]
    }
    assert PlayerHelper.get_minimum_player_goals_and_separate(input_p, input_t) == simulation_output

    input_p = [%{nivel: "B"}, %{nivel: "e"}, %{nivel: "F5"}]
    input_t = "aefae98f1381fae"

    simulation_output = %{
      error: [
        { :error,  "Nivel no registrado en el equipo #{input_t} para jugador " },
        { :error,  "Nivel no registrado en el equipo #{input_t} para jugador " },
        { :error,  "Nivel no registrado en el equipo #{input_t} para jugador " }
      ]
    }
    assert PlayerHelper.get_minimum_player_goals_and_separate(input_p, input_t) == simulation_output

  end

  test "Testing function to group by tuples and maps" do
    # When input is map
    input = %{}
    simulation_output = :players
    assert PlayerHelper.filter_maps_tuples( input ) == simulation_output

    # When input is tuple
    input = {}
    simulation_output = :error
    assert PlayerHelper.filter_maps_tuples( input ) == simulation_output
  end

  test "Calculating and getting the individual_compliance for a players group " do
    # When all the levels are registered and its Resuelve FC
    input_p = [
      %{nivel: "B", goles: 7},
      %{nivel: "A", goles: 5},
      %{nivel: "A", goles: 9},
      %{nivel: "Cuauh", goles: 23},
      %{nivel: "C", goles: 0} ]
    input_t = nil
    simulation_output = %{
      players: [
        %{ nivel: "B", goles: 7, goles_minimos: 10, individual_compliance: 70.0 },
        %{ nivel: "A", goles: 5, goles_minimos: 5, individual_compliance:  100.0},
        %{ nivel: "A", goles: 9, goles_minimos: 5, individual_compliance:  100.0},
        %{ nivel: "Cuauh", goles: 23, goles_minimos: 20, individual_compliance: 100.0 },
        %{ nivel: "C", goles: 0, goles_minimos: 15, individual_compliance: 0.0 }
      ],
      errors: nil
    }
    assert PlayerHelper.get_individual_compliance_players( input_p, input_t ) == simulation_output
  end

  test "Calculating the team compliance" do
    # When players have registered levels and its team is registered
    input_p = %{
      players: [
        %{nivel: "B", goles: 7, equipo: "azul", goles_minimos: 10},
        %{nivel: "A", goles: 5, equipo: "azul", goles_minimos: 5},
        %{nivel: "A", goles: 9, equipo: "verde", goles_minimos: 5},
        %{nivel: "Cuauh", goles: 23, equipo: "rojo", goles_minimos: 20},
        %{nivel: "C", goles: 0, equipo: "morado", goles_minimos: 15}
      ],
      errors: [
        { :error,  "Nivel no registrado para jugador " },
      ]
    }
    simulation_output = %{
      players: [
        [
          %{ nivel: "B", goles: 7, goles_minimos: 10,  team_compliance: 80.0, equipo: "azul"},
          %{ nivel: "A", goles: 5, goles_minimos: 5, team_compliance: 80.0, equipo: "azul"}
        ],
        [%{ nivel: "C", goles: 0, goles_minimos: 15, team_compliance: 0.0 , equipo: "morado"}],
        [%{ nivel: "Cuauh", goles: 23, goles_minimos: 20,  team_compliance: 100.0, equipo: "rojo"}],
        [%{ nivel: "A", goles: 9, goles_minimos: 5, team_compliance: 100.0, equipo: "verde"}]
      ],
      errors: [
        { :error,  "Nivel no registrado para jugador " },
      ]
    }
    assert PlayerHelper.calculate_teams_compliance( input_p ) == simulation_output
  end

  test "Calculating the global compliance" do

    input = %{individual_compliance: 100.0, team_compliance: 100.0}
    simulation_output = 100.0

    assert PlayerHelper.calculate_global_comp_single_player( input ) == simulation_output

    input = %{individual_compliance: 100, team_compliance: 90}
    simulation_output = 95.0

    assert PlayerHelper.calculate_global_comp_single_player( input ) == simulation_output

    input = %{individual_compliance: 0, team_compliance: 50}
    simulation_output = 25.0

    assert PlayerHelper.calculate_global_comp_single_player( input ) == simulation_output

  end

  test "Getting the global compliance for a players groups" do
    input_p = [
        %{goles: 15, nivel: "C", equipo: "rojo", individual_compliance: 100.0, team_compliance: 100.0},
        %{goles: 18, nivel: "Cuauh", equipo: "verde", individual_compliance: 100, team_compliance: 90},
        %{goles: 10, nivel: "Cuauh", equipo: "morado", individual_compliance: 0, team_compliance: 50},
        %{goles: 0, nivel: "A", equipo: "azul", individual_compliance: 0, team_compliance: 0}
    ]
    input_t = nil
    simulation_output = %{
      players: [
        %{goles: 0, nivel: "A", individual_compliance: 0.0, team_compliance: 0.0, global_compliance: 0.0, equipo: "azul", goles_minimos: 5},
        %{goles: 10, nivel: "Cuauh", individual_compliance: 50.0, team_compliance: 50.0, global_compliance: 50.0, equipo: "morado", goles_minimos: 20},
        %{goles: 15, nivel: "C", individual_compliance: 100.0, team_compliance: 100.0, global_compliance: 100.0, equipo: "rojo", goles_minimos: 15},
        %{goles: 18, nivel: "Cuauh", individual_compliance: 90.0, team_compliance: 90.0, global_compliance: 90.0, equipo: "verde", goles_minimos: 20}
      ],
      errors: nil
    }
    assert PlayerHelper.get_global_compliance_players( input_p , input_t ) == simulation_output
  end

end
