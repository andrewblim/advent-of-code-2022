defmodule Day13 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn x ->
      String.split(x, "\n") |> Enum.map(&parse_entry/1)
    end)
  end

  def parse_entry(x) do
    # TODO: do this without eval
    Code.eval_string(x) |> elem(0)
  end

  def compare(l, r) do
    case {l, r} do
      {l, r} when is_integer(l) and is_integer(r) and l < r -> :correct
      {l, r} when is_integer(l) and is_integer(r) and l > r -> :wrong
      {l, r} when is_integer(l) and is_integer(r) and l == r -> :unknown
      {[], [_ | _]} -> :correct
      {[_ | _], []} -> :wrong
      {[], []} -> :unknown
      {[l_head | l_rest], [r_head | r_rest]} ->
        case compare(l_head, r_head) do
          :correct -> :correct
          :wrong -> :wrong
          :unknown -> compare(l_rest, r_rest)
        end
      {l, r} when is_integer(l) and is_list(r) -> compare([l], r)
      {l, r} when is_list(l) and is_integer(r) -> compare(l, [r])
    end
  end

  def sorter(l, r) do
    case compare(l, r) do
      :wrong -> false
      _ -> true
    end
  end

  def problem1(input \\ "data/day13.txt", type \\ :file) do
    read_input(input, type)
    |> Enum.map(fn [x, y] -> compare(x, y) end)
    |> Enum.with_index(1)
    |> Enum.filter(fn {x, _} -> x == :correct end)
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.sum()
  end

  def problem2(input \\ "data/day13.txt", type \\ :file) do
    input = read_input(input, type) |> Enum.flat_map(fn [x, y] -> [x, y] end)
    input = [[[2]] | input]
    input = [[[6]] | input]
    input
    |> Enum.sort(&sorter/2)
    |> Enum.with_index(1)
    |> Enum.filter(fn {x, _} -> x == [[2]] or x == [[6]] end)
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.product()
  end
end
