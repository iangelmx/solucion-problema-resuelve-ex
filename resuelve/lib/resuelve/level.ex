defmodule Resuelve.Level do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "levels" do
    field :level_name, :string, primary_key: true
    field :min_goals, :integer
    field :team_name, :string, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(level, attrs) do
    level
    |> cast(attrs, [:level_name, :min_goals, :team_name])
    |> unique_constraint(:constraint_unique_level_by_team, name: :index_unique_level_by_team)
    |> validate_required([:level_name, :min_goals, :team_name])
  end
end
