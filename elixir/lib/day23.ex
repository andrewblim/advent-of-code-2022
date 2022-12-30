defmodule Day23 do
  def read_input(input, type \\ :file) do
    lines = Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    for {line, x} <- Enum.with_index(lines),
        {ch, y} <- Enum.with_index(String.graphemes(line)),
        ch == "#",
        into: %{} do
      {{x, y}, ch}
    end
  end

  def neighbors({x, y}) do
    [
      {x - 1, y - 1},
      {x - 1, y},
      {x - 1, y + 1},
      {x, y - 1},
      {x, y + 1},
      {x + 1, y - 1},
      {x + 1, y},
      {x + 1, y + 1},
    ]
  end

  def neighbors_n({x, y}) do
    [{x - 1, y - 1}, {x - 1, y}, {x - 1, y + 1}]
  end

  def neighbors_s({x, y}) do
    [{x + 1, y - 1}, {x + 1, y}, {x + 1, y + 1}]
  end

  def neighbors_w({x, y}) do
    [{x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1}]
  end

  def neighbors_e({x, y}) do
    [{x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}]
  end

  def unoccupied?(pts, map) do
    Enum.all?(pts, fn pt -> not Map.has_key?(map, pt) end)
  end

  def proposal_move({x, y}, map, directions) do
    case directions do
      [] -> {x, y}
      [:north | rest] ->
        if unoccupied?(neighbors_n({x, y}), map), do: {x - 1, y}, else: proposal_move({x, y}, map, rest)
      [:south | rest] ->
        if unoccupied?(neighbors_s({x, y}), map), do: {x + 1, y}, else: proposal_move({x, y}, map, rest)
      [:west | rest] ->
        if unoccupied?(neighbors_w({x, y}), map), do: {x, y - 1}, else: proposal_move({x, y}, map, rest)
      [:east | rest] ->
        if unoccupied?(neighbors_e({x, y}), map), do: {x, y + 1}, else: proposal_move({x, y}, map, rest)
    end
  end

  def proposal({x, y}, map, directions) do
    cond do
      unoccupied?(neighbors({x, y}), map) -> {x, y}
      true -> proposal_move({x, y}, map, directions)
    end
  end

  def all_proposals(map, directions) do
    for {x, y} <- Map.keys(map), into: %{}, do: {{x, y}, proposal({x, y}, map, directions)}
  end

  def move(map, proposals) do
    moves = for {elf, prop} <- proposals, reduce: %{} do
      acc -> Map.update(acc, prop, elf, fn _ -> nil end)
    end
    for {prop, elf} <- moves, not is_nil(elf), reduce: map do
      acc ->
        acc |> Map.delete(elf) |> Map.put(prop, "#")
    end
  end

  def run_round(map, n \\ 1, directions \\ [:north, :south, :west, :east]) do
    if n <= 0 do
      map
    else
      proposals = all_proposals(map, directions)
      new_map = move(map, proposals)
      [x | rest] = directions
      new_directions = rest ++ [x]
      run_round(new_map, n - 1, new_directions)
    end
  end

  def print_map(map) do
    xs = Map.keys(map) |> Enum.map(fn {x, _} -> x end)
    ys = Map.keys(map) |> Enum.map(fn {_, y} -> y end)
    min_x = Enum.min(xs)
    max_x = Enum.max(xs)
    min_y = Enum.min(ys)
    max_y = Enum.max(ys)
    output = for x <- min_x..max_x do
      for y <- min_y..max_y do
        if Map.has_key?(map, {x, y}), do: "#", else: "."
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
    IO.puts(output)
    map
  end

  def empties(map) do
    xs = Map.keys(map) |> Enum.map(fn {x, _} -> x end)
    ys = Map.keys(map) |> Enum.map(fn {_, y} -> y end)
    min_x = Enum.min(xs)
    max_x = Enum.max(xs)
    min_y = Enum.min(ys)
    max_y = Enum.max(ys)
    (max_x - min_x + 1) * (max_y - min_y + 1) - map_size(map)
  end

  def run_until_same(map, directions \\ [:north, :south, :west, :east], prev_map \\ nil, n \\ 0) do
    if map == prev_map do
      n
    else
      proposals = all_proposals(map, directions)
      new_map = move(map, proposals)
      [x | rest] = directions
      new_directions = rest ++ [x]
      run_until_same(new_map, new_directions, map, n + 1)
    end
  end

  def problem1(input \\ "data/day23.txt", type \\ :file) do
    read_input(input, type)
    |> run_round(10)
    |> empties()
  end

  def problem2(input \\ "data/day23.txt", type \\ :file) do
    read_input(input, type)
    |> run_until_same()
  end
end
