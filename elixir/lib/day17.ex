defmodule Day17 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
  end

  def add_pieces(dirs, n) do
    init_grid = for x <- 1..7, into: MapSet.new(), do: {x, 0}
    init_floor = for x <- 1..7, into: %{}, do: {x, 0}  # track floor separately for speed
    piece_type_order = [:hline, :cross, :ell, :vline, :box]
    for piece_type <- Enum.take(Stream.cycle(piece_type_order), n), reduce: {init_grid, init_floor, 0} do
      {grid, floor, i} ->
        {x, y} = {3, Enum.max(Map.values(floor)) + 4}
        piece = case piece_type do
          :hline -> MapSet.new([{x, y}, {x + 1, y}, {x + 2, y}, {x + 3, y}])
          :cross -> MapSet.new([{x, y + 1}, {x + 1, y}, {x + 1, y + 1}, {x + 1, y + 2}, {x + 2, y + 1}])
          :ell -> MapSet.new([{x, y}, {x + 1, y}, {x + 2, y}, {x + 2, y + 1}, {x + 2, y + 2}])
          :vline -> MapSet.new([{x, y}, {x, y + 1}, {x, y + 2}, {x, y + 3}])
          :box -> MapSet.new([{x, y}, {x, y + 1}, {x + 1, y}, {x + 1, y + 1}])
        end
        move_piece(grid, floor, piece, dirs, i)
    end
  end

  def occupied?(grid, {x, y}) do
    x <= 0 or x >= 8 or MapSet.member?(grid, {x, y})
  end

  def any_occupied?(grid, pts) do
    Enum.any?(pts, fn pt -> occupied?(grid, pt) end)
  end

  def move_piece(grid, floor, piece, dirs, i) do
    dir = String.slice(dirs, i..i)
    shifted = case dir do
      "<" -> for {x, y} <- piece, into: MapSet.new(), do: {x - 1, y}
      ">" -> for {x, y} <- piece, into: MapSet.new(), do: {x + 1, y}
    end
    piece = if any_occupied?(grid, shifted), do: piece, else: shifted
    shifted = for {x, y} <- piece, into: MapSet.new(), do: {x, y - 1}
    cond do
      any_occupied?(grid, shifted) ->
        grid = MapSet.union(grid, piece)
        floor = for {x, y} <- piece, reduce: floor do
          acc -> Map.update!(acc, x, fn y1 -> max(y, y1) end)
        end
        {grid, floor, rem(i + 1, String.length(dirs))}
      true ->
        move_piece(grid, floor, shifted, dirs, rem(i + 1, String.length(dirs)))
    end
  end

  def clean_grid(grid, floor) do
    MapSet.filter(grid, fn {x, y} -> y >= floor[x] end)
  end

  def problem1(input \\ "data/day17.txt", type \\ :file) do
    input = read_input(input, type)
    {_, floor, _} = add_pieces(input, 2022)
    Enum.max(Map.values(floor))
  end

  def problem2(input \\ "data/day16.txt", type \\ :file) do
    read_input(input, type)
  end
end
