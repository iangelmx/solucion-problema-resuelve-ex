defmodule Resuelve.Level do
  use Ecto.Schema
  import Ecto.Changeset

  schema "levels" do
    field :level, :string
    field :min_goals, :integer

    timestamps()
  end

  @doc false
  def changeset(level, attrs) do
    level
    |> cast(attrs, [:level, :min_goals])
    |> validate_required([:level, :min_goals])
  end
end
