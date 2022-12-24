defmodule Day17 do
  import Bitwise

  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
  end

  def add_pieces(dirs, n) do
    grid = for x <- 1..7, into: MapSet.new(), do: {x, 0}
    heights = for x <- 1..7, into: Map.new(), do: {x, 0}
    dirs = String.graphemes(dirs)
    |> Enum.with_index()
    |> Enum.map(fn {dir, i} -> {i, dir} end)
    |> Map.new()

    piece_type_order = [:hline, :cross, :ell, :vline, :box]
    for piece_type <- Enum.take(Stream.cycle(piece_type_order), n), reduce: {grid, heights, 0} do
      {grid, heights, i} ->
        {x, y} = {3, Enum.max(Map.values(heights)) + 4}
        piece = case piece_type do
          :hline -> MapSet.new([{x, y}, {x + 1, y}, {x + 2, y}, {x + 3, y}])
          :cross -> MapSet.new([{x, y + 1}, {x + 1, y}, {x + 1, y + 1}, {x + 1, y + 2}, {x + 2, y + 1}])
          :ell -> MapSet.new([{x, y}, {x + 1, y}, {x + 2, y}, {x + 2, y + 1}, {x + 2, y + 2}])
          :vline -> MapSet.new([{x, y}, {x, y + 1}, {x, y + 2}, {x, y + 3}])
          :box -> MapSet.new([{x, y}, {x, y + 1}, {x + 1, y}, {x + 1, y + 1}])
        end
        move_piece(grid, heights, piece, dirs, i)
    end
  end

  def occupied?(grid, {x, y}) do
    x <= 0 or x >= 8 or MapSet.member?(grid, {x, y})
  end

  def any_occupied?(grid, pts) do
    Enum.any?(pts, fn pt -> occupied?(grid, pt) end)
  end

  def move_piece(grid, heights, piece, dirs, i) do
    dir = dirs[i]
    shifted = case dir do
      "<" -> for {x, y} <- piece, into: MapSet.new(), do: {x - 1, y}
      ">" -> for {x, y} <- piece, into: MapSet.new(), do: {x + 1, y}
    end
    piece = if any_occupied?(grid, shifted), do: piece, else: shifted
    shifted = for {x, y} <- piece, into: MapSet.new(), do: {x, y - 1}
    cond do
      any_occupied?(grid, shifted) ->
        grid = MapSet.union(grid, piece)
        heights = for {x, y} <- piece, reduce: heights do
          acc -> Map.update!(acc, x, fn ht -> max(y, ht) end)
        end
        {grid, heights, rem(i + 1, map_size(dirs))}
      true ->
        move_piece(grid, heights, shifted, dirs, rem(i + 1, map_size(dirs)))
    end
  end

  def add_pieces2(dirs, n) do
    grid = 127
    dirs = String.graphemes(dirs)
    |> Enum.with_index()
    |> Enum.map(fn {dir, i} -> {i, dir} end)
    |> Map.new()

    # From most to least significant digit (least significant = "top")
    #
    # hline:
    # 0011110 = 30
    #
    # cross:
    # 0001000 = 8
    # 0011100 = 28
    # 0001000 = 8 => 531464
    #
    # ell:
    # 0000100 = 4
    # 0000100 = 4
    # 0011100 = 28 => 1836036
    #
    # vline:
    # 0010000 = 16
    # 0010000 = 16
    # 0010000 = 16
    # 0010000 = 16 => 269488144
    #
    # box:
    # 0011000 = 24
    # 0011000 = 24 => 6168

    piece_order = [{30, 1}, {531464, 3}, {1836036, 3}, {269488144, 4}, {6168, 2}]
    for {piece, piece_height} <- Enum.take(Stream.cycle(piece_order), n), reduce: {grid, 0} do
      {grid, i} ->
        move_piece2(grid, {piece, piece_height}, dirs, i, -3 - piece_height)
    end
  end

  def move_piece2(grid, {piece, piece_height}, dirs, i, offset) do
    shifted = case dirs[i] do
      "<" -> if blocked_left(grid, piece, offset), do: piece, else: piece <<< 1
      ">" -> if blocked_right(grid, piece, offset), do: piece, else: piece >>> 1
    end
    dropped = shifted <<< (offset + 1) * 8
    cond do
      (dropped &&& grid) == 0 ->
        move_piece2(grid, {shifted, piece_height}, dirs, rem(i + 1, map_size(dirs)), offset + 1)
      true ->
        grid_shift = max(-offset, 0)
        piece_shift = max(offset, 0)
        {(grid <<< (grid_shift * 8)) ||| (shifted <<< (piece_shift * 8)), rem(i + 1, map_size(dirs))}
    end
  end

  def blocked_left(grid, piece, offset) do
    (piece &&& 1077952576) != 0 or ((piece <<< (offset * 8 + 1)) &&& grid) != 0
  end

  def blocked_right(grid, piece, offset) do
    (piece &&& 16843009) != 0 or ((piece <<< (offset * 8 - 1)) &&& grid) != 0
  end

  def grid_height(grid, ht \\ -1) do
    if grid == 0, do: ht, else: grid_height(grid >>> 8, ht + 1)
  end

  def print_grid(grid) do
    if grid > 0 do
      IO.puts(Integer.to_string(rem(grid, 256), 2) |> String.replace("0", ".") |> String.pad_leading(7, "."))
      print_grid(grid >>> 8)
    end
  end

  def problem1(input \\ "data/day17.txt", type \\ :file) do
    input = read_input(input, type)
    {_, heights, _} = add_pieces(input, 2022)
    Enum.max(Map.values(heights))
  end

  def problem2(input \\ "data/day17.txt", type \\ :file) do
    input = read_input(input, type)
    {grid, _} = add_pieces2(input, 1_000_000)
    grid_height(grid)
  end
end
