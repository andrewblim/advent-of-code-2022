defmodule Day14 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn row ->
      String.split(row, " -> ")
      |> Enum.map(fn entry ->
        [x, y] = String.split(entry, ",")
        {String.to_integer(x), String.to_integer(y)}
      end)
    end)
  end

  def add_rocks(map, {x1, y1}, {x2, y2}) do
    cond do
      x1 == x2 ->
        for y <- (y1..y2), into: map do
          {{x1, y}, "#"}
        end
      y1 == y2 ->
        for x <- (x1..x2), into: map do
          {{x, y1}, "#"}
        end
    end
  end

  def add_lines_of_rocks(map, pts) do
    for [pt1, pt2] <- Enum.chunk_every(pts, 2, 1), reduce: map do
      acc -> add_rocks(acc, pt1, pt2)
    end
  end

  def initial_map(data) do
    for pts <- data, reduce: %{} do
      acc -> add_lines_of_rocks(acc, pts)
    end
  end

  def lowest_rock_by_col(map) do
    for {{x, y}, _} <- map, reduce: %{} do
      acc -> Map.update(acc, x, y, fn y1 -> max(y, y1) end)
    end
  end

  def falls_forever?(lowests, {x, y}) do
    case Map.get(lowests, x, nil) do
      nil -> true
      lowest when lowest < y -> true
      lowest when lowest > y -> false
    end
  end

  def move_sand(map, lowests, {x, y}) do
    cond do
      falls_forever?(lowests, {x, y}) ->
        {map, :fell_forever}
      not Map.has_key?(map, {x, y + 1}) ->
        move_sand(map, lowests, {x, y + 1})
      not Map.has_key?(map, {x - 1, y + 1}) ->
        move_sand(map, lowests, {x - 1, y + 1})
      not Map.has_key?(map, {x + 1, y + 1}) ->
        move_sand(map, lowests, {x + 1, y + 1})
      not Map.has_key?(map, {x, y}) ->
        {Map.put(map, {x, y}, "o"), :added}
    end
  end

  def fill_sand(map, lowests, {start_x, start_y}) do
    {map, result} = move_sand(map, lowests, {start_x, start_y})
    case result do
      :fell_forever -> map
      _ -> fill_sand(map, lowests, {start_x, start_y})
    end
  end

  def find_floor(map) do
    highest_y = map
    |> Map.keys()
    |> Enum.map(fn {_, y} -> y end)
    |> Enum.max()
    highest_y + 2
  end

  def move_sand2(map, floor, {x, y}) do
    cond do
      y == floor - 1 ->
        {Map.put(map, {x, y}, "o"), :added}
      not Map.has_key?(map, {x, y + 1}) ->
        move_sand2(map, floor, {x, y + 1})
      not Map.has_key?(map, {x - 1, y + 1}) ->
        move_sand2(map, floor, {x - 1, y + 1})
      not Map.has_key?(map, {x + 1, y + 1}) ->
        move_sand2(map, floor, {x + 1, y + 1})
      true ->
        {Map.put(map, {x, y}, "o"), :added}
    end
  end

  def fill_sand2(map, floor, {start_x, start_y}) do
    {map, _} = move_sand2(map, floor, {start_x, start_y})
    if Map.has_key?(map, {start_x, start_y}) do
      map
    else
      fill_sand2(map, floor, {start_x, start_y})
    end
  end

  def problem1(input \\ "data/day14.txt", type \\ :file) do
    map = read_input(input, type)
    |> initial_map()
    lowests = lowest_rock_by_col(map)
    final_map = fill_sand(map, lowests, {500, 0})
    final_map
    |> Enum.filter(fn {_, v} -> v == "o" end)
    |> Enum.count()
  end

  def problem2(input \\ "data/day14.txt", type \\ :file) do
    map = read_input(input, type)
    |> initial_map()
    floor = find_floor(map)
    final_map = fill_sand2(map, floor, {500, 0})
    final_map
    |> Enum.filter(fn {_, v} -> v == "o" end)
    |> Enum.count()
  end
end
