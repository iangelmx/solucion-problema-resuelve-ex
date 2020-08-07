defmodule Resuelve.Repo.Migrations.CreateLevels do
  use Ecto.Migration

  def change do
    create table(:levels) do
      add :level, :string
      add :min_goals, :integer

      timestamps()
    end

  end
end
