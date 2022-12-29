defmodule Day20 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  # at each step, multiply new * old
  # to generate a matrix, need
  # - the number we want to move
  # - its current position
  # current position = old * (1 vector at the desired position)

  def find_after_shift(numbers, ns) do
    shifted = shift(numbers)
    case Enum.find(shifted, fn {_, v} -> v == 0 end) do
      {{zero_pos, 1}, 0} ->
        for n <- ns do
          pos = wrap(zero_pos + n, map_size(shifted))
          shifted[{pos, 1}]
        end
        |> Enum.sum()
    end
  end

  def shift(numbers) do
    identity = for i <- 1..length(numbers), into: %{}, do: {{i, i}, 1}
    numbers_vector = for {number, i} <- Enum.with_index(numbers), into: %{}, do: {{i + 1, 1}, number}
    trans_matrix = for {number, i} <- Enum.with_index(numbers), reduce: identity do
      acc -> update_matrix(acc, number, i + 1, identity)
    end
    mmult(trans_matrix, numbers_vector)
  end

  def update_matrix(current, number, orig_i, identity) do
    [{cur_i, 1}] = mmult(current, %{{orig_i, 1} => 1}) |> Map.keys()
    update = next_matrix(rem(number, map_size(identity) - 1), cur_i, identity)
    mmult_fast(update, current)
  end

  def next_matrix(n, row, identity) do
    cond do
      n > 0 ->
        bumped = for i <- row..(row + n - 1)//1, j = wrap(i, map_size(identity)), reduce: identity do
          acc ->
            acc
            |> Map.delete({j, j})
            |> Map.put({j, wrap(j + 1, map_size(identity))}, 1)
        end
        target = wrap(row + n, map_size(identity))
        bumped
        |> Map.delete({target, target})
        |> Map.put({target, row}, 1)
      n < 0 ->
        bumped = for i <- row..(row + n + 1)//-1, j = wrap(i, map_size(identity)), reduce: identity do
          acc ->
            acc
            |> Map.delete({j, j})
            |> Map.put({j, wrap(j - 1, map_size(identity))}, 1)
        end
        target = wrap(row + n, map_size(identity))
        bumped
        |> Map.delete({target, target})
        |> Map.put({target, row}, 1)
      n == 0 -> identity
    end
  end

  def wrap(i, n) do
    Integer.mod(i - 1, n) + 1
  end

  def mmult(m1, m2) do
    for {{x1, y1}, v1} <- m1, {{x2, y2}, v2} <- m2, y1 == x2, into: %{} do
      {{x1, y2}, v1 * v2}
    end
  end

  def mmult_fast(m1, m2) do
    # specific to transition matrices, relies on there being only one element per row & col
    elements1 = Map.keys(m1) |> Enum.sort_by(fn {_, y} -> y end)
    elements2 = Map.keys(m2) |> Enum.sort_by(fn {x, _} -> x end)
    for {{x1, y1}, {x2, y2}} <- Enum.zip(elements1, elements2), into: %{} do
      {{x1, y2}, m1[{x1, y1}] * m2[{x2, y2}]}
    end
  end

  def problem1(input \\ "data/day20.txt", type \\ :file) do
    read_input(input, type)
    |> find_after_shift([1000, 2000, 3000])
  end

  def problem2(input \\ "data/day20.txt", type \\ :file) do
    read_input(input, type)
  end
end
