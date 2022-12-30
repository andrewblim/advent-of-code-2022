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

  def move(state, map, directions) do
    case directions do
      [] -> state
      [n | rest] when is_integer(n) ->
        walk(state, n, map) |> move(map, rest)
      [rot | rest] when rot == "R" or rot == "L" ->
        rotate(state, rot) |> move(map, rest)
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

  def walk(state, n, map) do
    for _ <- 1..n, reduce: {state, :free} do
      {state, moveable} ->
        case moveable do
          :free -> walk_step(state, map)
          :blocked -> {state, :blocked}
        end
    end
    |> elem(0)
  end

  def walk_step({x, y, dir}, map) do
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

  def move2(state, map, directions, edges) do
    case directions do
      [] -> state
      [n | rest] when is_integer(n) ->
        walk2(state, n, map, edges) |> move2(map, rest, edges)
      [rot | rest] when rot == "R" or rot == "L" ->
        rotate(state, rot) |> move2(map, rest, edges)
    end
  end

  def walk2(state, n, map, edges) do
    for _ <- 1..n, reduce: {state, :free} do
      {state, moveable} ->
        case moveable do
          :free -> walk_step2(state, map, edges)
          :blocked -> {state, :blocked}
        end
    end
    |> elem(0)
  end

  def walk_step2({x, y, dir}, map, edges) do
    {new_x, new_y, new_dir} = cond do
      Map.has_key?(edges, {x, y, dir}) -> edges[{x, y, dir}]
      dir == :up and Map.has_key?(map, {x - 1, y}) ->
        {x - 1, y, dir}
      dir == :down and Map.has_key?(map, {x + 1, y}) ->
        {x + 1, y, dir}
      dir == :left and Map.has_key?(map, {x, y - 1}) ->
        {x, y - 1, dir}
      dir == :right and Map.has_key?(map, {x, y + 1}) ->
        {x, y + 1, dir}
      true ->
        IO.inspect({x, y, dir})
        raise "oops"
    end
    case map[{new_x, new_y}] do
      "." -> {{new_x, new_y, new_dir}, :free}
      "#" -> {{x, y, dir}, :blocked}
    end
  end

  def first_square(map) do
    start_y = Map.keys(map)
    |> Enum.filter(fn {x, _} -> x == 0 end)
    |> Enum.map(fn {_, y} -> y end)
    |> Enum.min()
    {0, start_y}
  end

  # hardcoded for my input, sorry
  def edge_map() do
    map = %{}

    # curl the corners

    # bottom of 2 -> right of 3
    edge1 = for y <- 100..149, do: {49, y}
    edge2 = for x <- 50..99, do: {x, 99}
    map = for {{x1, y1}, {x2, y2}} <- Enum.zip(edge1, edge2), reduce: map do
      acc -> acc
        |> Map.put({x1, y1, :down}, {x2, y2, :left})
        |> Map.put({x2, y2, :right}, {x1, y1, :up})
    end

    # bottom of 5 -> right of 6
    edge1 = for y <- 50..99, do: {149, y}
    edge2 = for x <- 150..199, do: {x, 49}
    map = for {{x1, y1}, {x2, y2}} <- Enum.zip(edge1, edge2), reduce: map do
      acc -> acc
        |> Map.put({x1, y1, :down}, {x2, y2, :left})
        |> Map.put({x2, y2, :right}, {x1, y1, :up})
    end

    # top of 4 -> left of 3
    edge1 = for y <- 0..49, do: {100, y}
    edge2 = for x <- 50..99, do: {x, 50}
    map = for {{x1, y1}, {x2, y2}} <- Enum.zip(edge1, edge2), reduce: map do
      acc -> acc
        |> Map.put({x1, y1, :up}, {x2, y2, :right})
        |> Map.put({x2, y2, :left}, {x1, y1, :down})
    end

    # remaining edges sequentially top to bottom

    # top of 1 -> left of 6
    edge1 = for y <- 50..99, do: {0, y}
    edge2 = for x <- 150..199, do: {x, 0}
    map = for {{x1, y1}, {x2, y2}} <- Enum.zip(edge1, edge2), reduce: map do
      acc -> acc
        |> Map.put({x1, y1, :up}, {x2, y2, :right})
        |> Map.put({x2, y2, :left}, {x1, y1, :down})
    end

    # top of 2 -> bottom of 6
    edge1 = for y <- 100..149, do: {0, y}
    edge2 = for y <- 0..49, do: {199, y}
    map = for {{x1, y1}, {x2, y2}} <- Enum.zip(edge1, edge2), reduce: map do
      acc -> acc
        |> Map.put({x1, y1, :up}, {x2, y2, :up})
        |> Map.put({x2, y2, :down}, {x1, y1, :down})
    end

    # left of 1 -> left of 4 (flipped)
    edge1 = for x <- 0..49, do: {x, 50}
    edge2 = for x <- 149..100, do: {x, 0}
    map = for {{x1, y1}, {x2, y2}} <- Enum.zip(edge1, edge2), reduce: map do
      acc -> acc
        |> Map.put({x1, y1, :left}, {x2, y2, :right})
        |> Map.put({x2, y2, :left}, {x1, y1, :right})
    end

    # right of 2 -> right of 5 (flipped)
    edge1 = for x <- 0..49, do: {x, 149}
    edge2 = for x <- 149..100, do: {x, 99}
    map = for {{x1, y1}, {x2, y2}} <- Enum.zip(edge1, edge2), reduce: map do
      acc -> acc
        |> Map.put({x1, y1, :right}, {x2, y2, :left})
        |> Map.put({x2, y2, :right}, {x1, y1, :left})
    end

    map
  end

  def problem1(input \\ "data/day22.txt", type \\ :file) do
    {map, directions} = read_input(input, type)
    {x, y} = first_square(map)
    move({x, y, :right}, map, directions)
    |> score_state()
  end

  def problem2(input \\ "data/day22.txt", type \\ :file) do
    {map, directions} = read_input(input, type)
    {x, y} = first_square(map)
    edges = edge_map()
    move2({x, y, :right}, map, directions, edges)
    |> score_state()
  end
end
