defmodule Day01 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim
    |> String.split("\n\n")
    |> Enum.map(fn x ->
      x |> String.split("\n") |> Enum.map(&String.to_integer/1)
    end)
  end

  def max_n_cals(input, n) do
    input |> Enum.map(&Enum.sum/1) |> Enum.sort(:desc) |> Enum.take(n) |> Enum.sum
  end

  def problem1(input \\ "data/day01.txt", type \\ :file) do
    read_input(input, type)
    |> max_n_cals(1)
  end

  def problem2(input \\ "data/day01.txt", type \\ :file) do
    read_input(input, type)
    |> max_n_cals(3)
  end
end
