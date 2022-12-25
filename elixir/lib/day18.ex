defmodule Day18 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn row ->
      [x, y, z] = String.split(row, ",") |> Enum.map(&String.to_integer/1)
      {x, y, z}
    end)
  end

  def sides({x, y, z}) do
    [
      {x + 0.5, y, z},
      {x - 0.5, y, z},
      {x, y + 0.5, z},
      {x, y - 0.5, z},
      {x, y, z + 0.5},
      {x, y, z - 0.5},
    ]
  end

  def surfaces(cubes) do
    sides = for cube <- cubes, side <- sides(cube), reduce: %{} do
      acc -> Map.update(acc, side, 1, fn x -> x + 1 end)
    end
    sides
    |> Enum.filter(fn {_, v} -> v == 1 end)
    |> Enum.map(fn {side, _} -> side end)
    |> MapSet.new()
  end

  def cube_bounds(cubes) do
    # includes a 1-cube border
    xs = Enum.map(cubes, fn cube -> elem(cube, 0) end)
    ys = Enum.map(cubes, fn cube -> elem(cube, 1) end)
    zs = Enum.map(cubes, fn cube -> elem(cube, 2) end)
    {
      {Enum.min(xs) - 1, Enum.max(xs) + 1},
      {Enum.min(ys) - 1, Enum.max(ys) + 1},
      {Enum.min(zs) - 1, Enum.max(zs) + 1},
    }
  end

  def neighbors({x, y, z}) do
    [
      {x - 1, y, z},
      {x + 1, y, z},
      {x, y - 1, z},
      {x, y + 1, z},
      {x, y, z - 1},
      {x, y, z + 1},
    ]
  end

  def in_bounds?({x, y, z}, {{min_x, max_x}, {min_y, max_y}, {min_z, max_z}}) do
    x >= min_x and x <= max_x and y >= min_y and y <= max_y and z >= min_z and z <= max_z
  end

  def reachable_space(current_spaces, visited_spaces, cubes, bounds) do
    next_spaces =
      for current_space <- current_spaces,
          space <- neighbors(current_space),
          in_bounds?(space, bounds),
          not MapSet.member?(visited_spaces, space),
          not MapSet.member?(cubes, space),
          into: MapSet.new() do
        space
      end
    case MapSet.size(next_spaces) do
      0 -> visited_spaces
      _ -> reachable_space(next_spaces, MapSet.union(next_spaces, visited_spaces), cubes, bounds)
    end
  end

  def reachable_surfaces(cubes) do
    bounds = cube_bounds(cubes)
    {{min_x, _}, {min_y, _}, {min_z, _}} = bounds
    initial_spaces = MapSet.new([{min_x, min_y, min_z}])
    spaces = reachable_space(initial_spaces, initial_spaces, MapSet.new(cubes), bounds)
    MapSet.intersection(surfaces(spaces), surfaces(cubes))
  end

  def problem1(input \\ "data/day18.txt", type \\ :file) do
    read_input(input, type)
    |> surfaces()
    |> MapSet.size()
  end

  def problem2(input \\ "data/day18.txt", type \\ :file) do
    read_input(input, type)
    |> reachable_surfaces()
    |> MapSet.size()
  end
end
