defmodule Day12 do
  def read_input(input, type \\ :file) do
    rows = Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    for {row, x} <- Enum.with_index(rows),
        {node, y} <- String.graphemes(row) |> Enum.with_index(),
        reduce: {%{}, nil, nil} do
      {points, start_point, end_point} ->
        case {node, start_point, end_point} do
          {"S", nil, end_point} -> {Map.put(points, {x, y}, "a"), {x, y}, end_point}
          {"E", start_point, nil} -> {Map.put(points, {x, y}, "z"), start_point, {x, y}}
          {node, start_point, end_point} -> {Map.put(points, {x, y}, node), start_point, end_point}
        end
    end
  end

  def convert_elevations(points) do
    for {pt, elev} <- points, into: %{} do
      case String.to_charlist(elev) do
        [x] -> {pt, x - 97}
      end
    end
  end

  def get_neighbors(points, {x, y}) do
    for pt <- [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}],
              cur_elev = Map.get(points, {x, y}),
              pt_elev = Map.get(points, pt),
              not is_nil(pt_elev),
              pt_elev - cur_elev <= 1 do
      pt
    end
  end

  def get_neighbors2(points, {x, y}) do
    for pt <- [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}],
              cur_elev = Map.get(points, {x, y}),
              pt_elev = Map.get(points, pt),
              not is_nil(pt_elev),
              cur_elev - pt_elev <= 1 do
      pt
    end
  end

  def find_shortest(points, current, target, visited, distances) do
    neighbors = get_neighbors(points, current)
    cur_distance = distances[current]
    distances = for pt <- neighbors, not MapSet.member?(visited, pt), reduce: distances do
      distances ->
        Map.update(distances, pt, cur_distance + 1, fn dist -> min(dist, cur_distance + 1) end)
    end
    visited = MapSet.put(visited, current)

    cond do
      MapSet.member?(visited, target) -> {distances, visited}
      true ->
        unvisited_reachable = Map.keys(distances)
        |> Enum.filter(fn x -> not MapSet.member?(visited, x) end)
        |> Enum.sort_by(fn x -> distances[x] end)

        case unvisited_reachable do
          [] -> {distances, visited}
          [nearest | _] -> find_shortest(points, nearest, target, visited, distances)
        end
    end
  end

  def find_shortest2(points, current, visited, distances) do
    neighbors = get_neighbors2(points, current)
    cur_distance = distances[current]
    distances = for pt <- neighbors, not MapSet.member?(visited, pt), reduce: distances do
      distances ->
        Map.update(distances, pt, cur_distance + 1, fn dist -> min(dist, cur_distance + 1) end)
    end
    visited = MapSet.put(visited, current)

    cond do
      true ->
        unvisited_reachable = Map.keys(distances)
        |> Enum.filter(fn x -> not MapSet.member?(visited, x) end)
        |> Enum.sort_by(fn x -> distances[x] end)

        case unvisited_reachable do
          [] -> {distances, visited}
          [nearest | _] -> find_shortest2(points, nearest, visited, distances)
        end
    end
  end

  def problem1(input \\ "data/day12.txt", type \\ :file) do
    {points, start, target} = read_input(input, type)
    points = convert_elevations(points)
    {distances, _} = find_shortest(points, start, target, MapSet.new, %{start => 0})
    distances[target]
  end

  def problem2(input \\ "data/day12.txt", type \\ :file) do
    {points, _, start} = read_input(input, type)
    points = convert_elevations(points)
    {distances, _} = find_shortest2(points, start, MapSet.new, %{start => 0})
    distances
    |> Enum.filter(fn {pt, _} -> points[pt] == 0 end)
    |> Enum.min_by(fn {_, dist} -> dist end)
  end
end
