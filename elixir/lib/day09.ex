defmodule Day09 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x ->
      [dir, steps] = x |> String.split(" ")
      {dir, String.to_integer(steps)}
    end)
  end

  def move_piece({x, y}, dir) do
    case dir do
      "R" -> {x + 1, y}
      "L" -> {x - 1, y}
      "U" -> {x, y + 1}
      "D" -> {x, y - 1}
    end
  end

  def tail_move({head_x, head_y}, {tail_x, tail_y}) do
    {move_x, move_y} = case {head_x - tail_x, head_y - tail_y} do
      {x, y} when -1 <= x and x <= 1 and -1 <= y and y <= 1 -> {0, 0}
      # horiz/vert
      {2, 0} -> {1, 0}
      {-2, 0} -> {-1, 0}
      {0, 2} -> {0, 1}
      {0, -2} -> {0, -1}
      # diagonals
      {2, 1} -> {1, 1}
      {1, 2} -> {1, 1}
      {2, 2} -> {1, 1}
      {-2, 1} -> {-1, 1}
      {-1, 2} -> {-1, 1}
      {-2, 2} -> {-1, 1}
      {2, -1} -> {1, -1}
      {1, -2} -> {1, -1}
      {2, -2} -> {1, -1}
      {-2, -1} -> {-1, -1}
      {-1, -2} -> {-1, -1}
      {-2, -2} -> {-1, -1}
    end
    {tail_x + move_x, tail_y + move_y}
  end

  def move_rope({dir, steps}, {head_x, head_y}, {tail_x, tail_y}, tail_visited) do
    for _ <- 0..(steps - 1), reduce: {{head_x, head_y}, {tail_x, tail_y}, tail_visited} do
      {{head_x, head_y}, {tail_x, tail_y}, visited} ->
        {new_head_x, new_head_y} = move_piece({head_x, head_y}, dir)
        {new_tail_x, new_tail_y} = tail_move({new_head_x, new_head_y}, {tail_x, tail_y})
        new_tail_visited = MapSet.put(visited, {{new_tail_x, new_tail_y}})
        {{new_head_x, new_head_y}, {new_tail_x, new_tail_y}, new_tail_visited}
    end
  end

  def move_rope2({dir, steps}, rope, tail_visited) do
    for _ <- 0..(steps - 1), reduce: {rope, tail_visited} do
      {[head_rope | tail_rope], tail_visited} ->
        new_head_rope = move_piece(head_rope, dir)
        {tail_piece, new_tail_rope} = for piece <- tail_rope, reduce: {new_head_rope, []} do
          {{x, y}, rope} ->
            new_piece = tail_move({x, y}, piece)
            {new_piece, [new_piece | rope]}
        end
        new_tail_rope = Enum.reverse(new_tail_rope)
        {[new_head_rope | new_tail_rope], MapSet.put(tail_visited, tail_piece)}
    end
  end

  def problem1(input \\ "data/day09.txt", type \\ :file) do
    moves = read_input(input, type)
    {_, _, tail_visited} = for {dir, steps} <- moves, reduce: {{0, 0}, {0, 0}, MapSet.new()} do
      {{head_x, head_y}, {tail_x, tail_y}, tail_visited} ->
        move_rope({dir, steps}, {head_x, head_y}, {tail_x, tail_y}, tail_visited)
    end
    MapSet.size(tail_visited)
  end

  def problem2(input \\ "data/day09.txt", type \\ :file) do
    moves = read_input(input, type)
    init_rope = for _ <- 0..9, do: {0, 0}
    {_, tail_visited} = for {dir, steps} <- moves, reduce: {init_rope, MapSet.new()} do
      {rope, tail_visited} ->
        move_rope2({dir, steps}, rope, tail_visited)
    end
    MapSet.size(tail_visited)
  end
end
