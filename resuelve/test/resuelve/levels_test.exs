defmodule Resuelve.LevelsTest do
  use Resuelve.DataCase

  alias Resuelve.Levels

  describe "levels" do
    alias Resuelve.Levels.Level

    @valid_attrs %{level: "some level", min_goals: 42}
    @update_attrs %{level: "some updated level", min_goals: 43}
    @invalid_attrs %{level: nil, min_goals: nil}

    def level_fixture(attrs \\ %{}) do
      {:ok, level} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Levels.create_level()

      level
    end

    test "list_levels/0 returns all levels" do
      level = level_fixture()
      assert Levels.list_levels() == [level]
    end

    test "get_level!/1 returns the level with given id" do
      level = level_fixture()
      assert Levels.get_level!(level.id) == level
    end

    test "create_level/1 with valid data creates a level" do
      assert {:ok, %Level{} = level} = Levels.create_level(@valid_attrs)
      assert level.level == "some level"
      assert level.min_goals == 42
    end

    test "create_level/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Levels.create_level(@invalid_attrs)
    end

    test "update_level/2 with valid data updates the level" do
      level = level_fixture()
      assert {:ok, %Level{} = level} = Levels.update_level(level, @update_attrs)
      assert level.level == "some updated level"
      assert level.min_goals == 43
    end

    test "update_level/2 with invalid data returns error changeset" do
      level = level_fixture()
      assert {:error, %Ecto.Changeset{}} = Levels.update_level(level, @invalid_attrs)
      assert level == Levels.get_level!(level.id)
    end

    test "delete_level/1 deletes the level" do
      level = level_fixture()
      assert {:ok, %Level{}} = Levels.delete_level(level)
      assert_raise Ecto.NoResultsError, fn -> Levels.get_level!(level.id) end
    end

    test "change_level/1 returns a level changeset" do
      level = level_fixture()
      assert %Ecto.Changeset{} = Levels.change_level(level)
    end
  end
end
