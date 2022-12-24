defmodule Day17 do
  import Bitwise

  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
  end

  def add_pieces(dirs, n, start_piece \\ 0, start_dir \\ 0, find_flat \\ false) do
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
    #
    # initial grid
    # 1111111 = 127

    grid = 127

    dirs = String.graphemes(dirs)
    |> Enum.with_index()
    |> Enum.map(fn {dir, i} -> {i, dir} end)
    |> Map.new()

    pieces = Stream.cycle([{30, 1}, {531464, 3}, {1836036, 3}, {269488144, 4}, {6168, 2}])
    |> Stream.with_index()
    |> Stream.drop(rem(start_piece, 5))

    for {{piece, piece_height}, piece_n} <- Enum.take(pieces, n), reduce: {grid, start_dir} do
      {grid, i} ->
        {new_grid, new_i} = move_piece(grid, {piece, piece_height}, dirs, i, -3 - piece_height)
        if find_flat and rem(new_grid, 256) == 127 do
          IO.puts(piece_n)
          IO.puts(piece)
          IO.puts(new_i)
          IO.puts(grid_height(new_grid))
          IO.puts("")
        end
        {new_grid, new_i}
    end
  end

  def move_piece(grid, {piece, piece_height}, dirs, i, offset) do
    shifted = case dirs[i] do
      "<" -> if blocked_left(grid, piece, offset), do: piece, else: piece <<< 1
      ">" -> if blocked_right(grid, piece, offset), do: piece, else: piece >>> 1
    end
    dropped = shifted <<< (offset + 1) * 8
    cond do
      (dropped &&& grid) == 0 ->
        move_piece(grid, {shifted, piece_height}, dirs, rem(i + 1, map_size(dirs)), offset + 1)
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
    {grid, _} = add_pieces(input, 2022)
    grid_height(grid)
  end

  def problem2(input \\ "data/day17.txt", type \\ :file) do
    input = read_input(input, type)

    # to find the cycles run:
    # add_pieces(input, 10000, 0, 0, true)
    #
    # on my input cycles every 1690 pieces starting with piece 1240 after placing a line
    # after 1240, 2930, 4620, etc. there is a flat line
    # with heights
    # (i = 7470 each time)
    #
    # (also: 1375, 3065, 4755, etc. where i = 8276 each time)

    # {grid, _} = add_pieces(input, 1241)
    # print_grid(grid)
    # IO.puts(rem(grid, 256))

    n = 1000000000000 # 1000000000000
    n_init = 1240
    n_cycles = Integer.floor_div(n - n_init, 1690)
    n_rem = rem(n - n_init, 1690)

    IO.inspect({n_init, n_cycles, n_rem})

    {grid_init, grid_init_i} = add_pieces(input, n_init + 1)
    {grid_rem, _} = add_pieces(input, n_rem - 1, n_init + 1, grid_init_i)
    grid_height(grid_init) + n_cycles * 2548 + grid_height(grid_rem)
  end
end
