defmodule Day24 do
  def read_input(input, type \\ :file) do
    lines = Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    for {line, x} <- Enum.with_index(lines),
        {ch, y} <- Enum.with_index(String.graphemes(line)),
        into: %{} do
      {{x, y}, ch}
    end
  end

  def map_data(map) do
    up = for {pt, ch} <- map, ch == "^", into: %{}, do: {pt, ch}
    down = for {pt, ch} <- map, ch == "v", into: %{}, do: {pt, ch}
    left = for {pt, ch} <- map, ch == "<", into: %{}, do: {pt, ch}
    right = for {pt, ch} <- map, ch == ">", into: %{}, do: {pt, ch}
    walls = for {pt, ch} <- map, ch == "#", into: %{}, do: {pt, ch}
    {up, down, left, right, walls}
  end

  def advance_blizzards({up, down, left, right, walls}) do
    {max_row, max_col} = Map.keys(walls) |> Enum.max()
    new_up = for {{x, y}, ch} <- up, into: %{} do
      if Map.has_key?(walls, {x - 1, y}) do
        {{max_row - 1, y}, ch}
      else
        {{x - 1, y}, ch}
      end
    end
    new_down = for {{x, y}, ch} <- down, into: %{} do
      if Map.has_key?(walls, {x + 1, y}) do
        {{1, y}, ch}
      else
        {{x + 1, y}, ch}
      end
    end
    new_left = for {{x, y}, ch} <- left, into: %{} do
      if Map.has_key?(walls, {x, y - 1}) do
        {{x, max_col - 1}, ch}
      else
        {{x, y - 1}, ch}
      end
    end
    new_right = for {{x, y}, ch} <- right, into: %{} do
      if Map.has_key?(walls, {x, y + 1}) do
        {{x, 1}, ch}
      else
        {{x, y + 1}, ch}
      end
    end
    {new_up, new_down, new_left, new_right, walls}
  end

  def print_map({up, down, left, right, walls}) do
    {max_row, max_col} = Map.keys(walls) |> Enum.max()
    output = for x <- 0..max_row do
      for y <- 0..max_col do
        ch = "."
        ch = if Map.has_key?(walls, {x, y}), do: "#", else: ch
        ch = if Map.has_key?(up, {x, y}), do: "^", else: ch
        ch = cond do
          Map.has_key?(down, {x, y}) and ch == "." -> "v"
          Map.has_key?(down, {x, y}) -> "2"
          true -> ch
        end
        ch = cond do
          Map.has_key?(left, {x, y}) and ch == "." -> "<"
          Map.has_key?(left, {x, y}) and ch == "2" -> "3"
          Map.has_key?(left, {x, y}) -> "2"
          true -> ch
        end
        ch = cond do
          Map.has_key?(right, {x, y}) and ch == "." -> ">"
          Map.has_key?(right, {x, y}) and ch == "3" -> "4"
          Map.has_key?(right, {x, y}) and ch == "2" -> "3"
          Map.has_key?(right, {x, y}) -> "2"
          true -> ch
        end
        ch
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
    IO.puts(output)
    nil
  end

  def bfs(map_data, current, goal, n \\ 0) do
    cond do
      MapSet.member?(current, goal) -> n
      MapSet.size(current) == 0 -> nil
      true ->
        {up, down, left, right, walls} = advance_blizzards(map_data)
        {max_row, max_col} = Map.keys(walls) |> Enum.max()
        next =
          for {x, y} <- current,
              {next_x, next_y} <- [{x, y}, {x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}],
              next_x >= 0,
              next_y >= 0,
              next_x <= max_row,
              next_y <= max_col,
              not Map.has_key?(up, {next_x, next_y}),
              not Map.has_key?(down, {next_x, next_y}),
              not Map.has_key?(left, {next_x, next_y}),
              not Map.has_key?(right, {next_x, next_y}),
              not Map.has_key?(walls, {next_x, next_y}),
              into: MapSet.new() do
            {next_x, next_y}
          end
        bfs({up, down, left, right, walls}, next, goal, n + 1)
    end
  end

  def problem1(input \\ "data/day24.txt", type \\ :file) do
    {up, down, left, right, walls} = read_input(input, type) |> map_data()
    {max_row, max_col} = Map.keys(walls) |> Enum.max()
    initial = {0, 1}
    goal = {max_row, max_col - 1}
    bfs({up, down, left, right, walls}, MapSet.new([initial]), goal)
  end

  def problem2(input \\ "data/day24.txt", type \\ :file) do
    read_input(input, type)
  end
end
