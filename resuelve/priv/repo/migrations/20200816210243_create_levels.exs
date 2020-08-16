defmodule Resuelve.Repo.Migrations.CreateLevels do
  use Ecto.Migration

  def change do
    create table(:levels, primary_key: false) do
      add :level_name, :string, primary_key: false
      add :min_goals, :integer

      timestamps()
    end

  end
end
