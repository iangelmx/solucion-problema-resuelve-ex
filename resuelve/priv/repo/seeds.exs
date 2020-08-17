# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Resuelve.Repo.insert!(%Resuelve.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Resuelve.{Repo, Level}

Repo.insert!(%Level{level_name: "A", min_goals: 5, team_name: "Resuelve FC"})
Repo.insert!(%Level{level_name: "B", min_goals: 10, team_name: "Resuelve FC"})
Repo.insert!(%Level{level_name: "C", min_goals: 15, team_name: "Resuelve FC"})
Repo.insert!(%Level{level_name: "Cuauh", min_goals: 20, team_name: "Resuelve FC"})
