defmodule Resuelve.Repo.Migrations.CreateLevels do
  use Ecto.Migration

  def change do
    create table(:levels, primary_key: false) do
      add :level_name, :string, primary_key: true
      add :min_goals, :integer
      add :team_name, :string, primary_key: true
      timestamps()
    end

    create unique_index(:levels, [:level_name, :team_name], name: :index_unique_level_by_team)
  end
end
