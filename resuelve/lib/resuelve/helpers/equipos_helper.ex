defmodule Resuelve.Helpers.EquiposHelper do

  def get_scored_goals_team( jugadores ) when length(jugadores)>0 do
    Enum.reduce(jugadores , 0, fn jugador, acc -> jugador.goles + acc end)
  end
  def get_scored_goals_team( jugadores ) do
    0
  end

  def get_goal_goals_team( jugadores ) when length(jugadores) > 0 do
    Enum.reduce(jugadores , 0, fn jugador, acc -> jugador.goles_minimos + acc end)
  end
  def get_goal_goals_team( jugadores ) do
    0
  end

  @spec get_scored_and_goal_goals_team( list( map() ) ) :: integer()
  def get_scored_and_goal_goals_team( jugadores ) when length(jugadores) > 0 do
    scored = get_scored_goals_team( jugadores )
    goal = get_goal_goals_team( jugadores )
    %{goal: goal, scored: scored}
  end
  def get_scored_and_goal_goals_team( jugadores ) do
    %{goal: 0, scored: 0}
  end

  @spec get_team_compliance( map() ) :: integer()
  def get_team_compliance( %{goal: goal,  scored: scored } ) when scored > goal do
    100
  end
  def get_team_compliance( %{goal: goal,  scored: scored } ) when scored < goal and scored > 0 do
    (scored * 100) / goal
  end
  def get_team_compliance( %{goal: goal,  scored: scored } ) do
    0
  end

end
