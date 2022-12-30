defmodule Day22 do
  def read_input(input, type \\ :file) do
    [map, directions] = Helpers.file_or_io(input, type)
    |> String.split("\n\n")
    {parse_map(map), parse_directions(directions)}
  end

  def parse_map(raw) do
    for {line, i} <- Enum.with_index(String.split(raw, "\n")),
        {ch, j} <- Enum.with_index(String.graphemes(line)),
        ch != " ",
        into: %{} do
      {{i, j}, ch}
    end
  end

  def parse_directions(raw, list \\ []) do
    case String.trim(raw) do
      "" -> Enum.reverse(list)
      "L" <> rest -> parse_directions(rest, ["L" | list])
      "R" <> rest -> parse_directions(rest, ["R" | list])
      _ ->
        [n, rest] = Regex.run(~r/^(\d+)(.*)/, raw, capture: :all_but_first)
        parse_directions(rest, [String.to_integer(n) | list])
    end
  end

  def move(map, state, directions) do
    case directions do
      [] -> state
      [n | rest] when is_integer(n) ->
        move(map, walk(map, state, n), rest)
      [rot | rest] when rot == "R" or rot == "L" ->
        move(map, rotate(state, rot), rest)
    end
  end

  def rotate({x, y, dir}, rot) do
    case {{x, y, dir}, rot} do
      {{x, y, :up}, "L"} -> {x, y, :left}
      {{x, y, :left}, "L"} -> {x, y, :down}
      {{x, y, :down}, "L"} -> {x, y, :right}
      {{x, y, :right}, "L"} -> {x, y, :up}
      {{x, y, :up}, "R"} -> {x, y, :right}
      {{x, y, :right}, "R"} -> {x, y, :down}
      {{x, y, :down}, "R"} -> {x, y, :left}
      {{x, y, :left}, "R"} -> {x, y, :up}
    end
  end

  def walk(map, state, n) do
    for _ <- 1..n, reduce: {state, :free} do
      {state, moveable} ->
        case moveable do
          :free -> walk_step(map, state)
          :blocked -> {state, :blocked}
        end
    end
    |> elem(0)
  end

  def walk_step(map, {x, y, dir}) do
    {new_x, new_y} = case dir do
      :up ->
        if Map.has_key?(map, {x - 1, y}) do
          {x - 1, y}
        else
          new_x = Map.keys(map)
          |> Enum.filter(fn {_, y1} -> y1 == y end)
          |> Enum.map(fn {x1, _} -> x1 end)
          |> Enum.max()
          {new_x, y}
        end
      :down ->
        if Map.has_key?(map, {x + 1, y}) do
          {x + 1, y}
        else
          new_x = Map.keys(map)
          |> Enum.filter(fn {_, y1} -> y1 == y end)
          |> Enum.map(fn {x1, _} -> x1 end)
          |> Enum.min()
          {new_x, y}
        end
      :left ->
        if Map.has_key?(map, {x, y - 1}) do
          {x, y - 1}
        else
          new_y = Map.keys(map)
          |> Enum.filter(fn {x1, _} -> x1 == x end)
          |> Enum.map(fn {_, y1} -> y1 end)
          |> Enum.max()
          {x, new_y}
        end
      :right ->
        if Map.has_key?(map, {x, y + 1}) do
          {x, y + 1}
        else
          new_y = Map.keys(map)
          |> Enum.filter(fn {x1, _} -> x1 == x end)
          |> Enum.map(fn {_, y1} -> y1 end)
          |> Enum.min()
          {x, new_y}
        end
    end
    case map[{new_x, new_y}] do
      "." -> {{new_x, new_y, dir}, :free}
      "#" -> {{x, y, dir}, :blocked}
    end
  end

  def score_state({x, y, dir}) do
    dir_score = case dir do
      :right -> 0
      :down -> 1
      :left -> 2
      :up -> 3
    end
    1000 * (x + 1) + 4 * (y + 1) + dir_score
  end

  def problem1(input \\ "data/day22.txt", type \\ :file) do
    {map, directions} = read_input(input, type)
    # map
    start_y = Map.keys(map)
    |> Enum.filter(fn {x, _} -> x == 0 end)
    |> Enum.map(fn {_, y} -> y end)
    |> Enum.min()
    move(map, {0, start_y, :right}, directions)
    |> score_state()
  end

  def problem2(input \\ "data/day22.txt", type \\ :file) do
    read_input(input, type)
  end
end
