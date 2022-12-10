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
      {x, y} when -1 <= x and x <= 1 and -1 <= y and y <= 1 ->
        {0, 0}
      {x, y} when -2 <= x and x <= 2 and -2 <= y and y <= 2 ->
        sgn_x = if x >= 0, do: 1, else: -1
        sgn_y = if y >= 0, do: 1, else: -1
        {min(1, abs(x)) * sgn_x, min(1, abs(y)) * sgn_y}
    end
    {tail_x + move_x, tail_y + move_y}
  end

  def move_rope({dir, steps}, {rope, visited}) do
    for _ <- 1..steps, reduce: {rope, visited} do
      {[head | tail], visited} ->
        head = move_piece(head, dir)
        {final_piece, tail} = for piece <- tail, reduce: {head, []} do
          {preceding_piece, rope} ->
            piece = tail_move(preceding_piece, piece)
            {piece, [piece | rope]}
        end
        tail = Enum.reverse(tail)
        {[head | tail], MapSet.put(visited, final_piece)}
    end
  end

  def problem1(input \\ "data/day09.txt", type \\ :file) do
    moves = read_input(input, type)
    init_rope = for _ <- 1..2, do: {0, 0}
    {_, tail_visited} = for {dir, steps} <- moves, reduce: {init_rope, MapSet.new()} do
      {rope, tail_visited} -> move_rope({dir, steps}, {rope, tail_visited})
    end
    MapSet.size(tail_visited)
  end

  def problem2(input \\ "data/day09.txt", type \\ :file) do
    moves = read_input(input, type)
    init_rope = for _ <- 1..10, do: {0, 0}
    {_, tail_visited} = for {dir, steps} <- moves, reduce: {init_rope, MapSet.new()} do
      {rope, tail_visited} -> move_rope({dir, steps}, {rope, tail_visited})
    end
    MapSet.size(tail_visited)
  end
end
