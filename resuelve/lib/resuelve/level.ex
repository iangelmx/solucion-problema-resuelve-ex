defmodule Resuelve.Level do
  use Ecto.Schema
  import Ecto.Changeset

  schema "levels" do
    field :level_name, :string
    field :min_goals, :integer

    timestamps()
  end

  @doc false
  def changeset(level, attrs) do
    level
    |> cast(attrs, [:level_name, :min_goals])
    |> validate_required([:level_name, :min_goals])
  end
end
