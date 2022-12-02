defmodule Day01 do
  def read_input(file) do
    {:ok, file} = File.read(file)
    file
    |> String.trim
    |> String.split("\n\n")
    |> Enum.map(fn x ->
      x |> String.split("\n") |> Enum.map(&String.to_integer/1)
    end)
  end

  def max_n_cals(input, n) do
    input |> Enum.map(&Enum.sum/1) |> Enum.sort(:desc) |> Enum.take(n) |> Enum.sum
  end

  def problem1() do
    read_input("data/day01.txt")
    |> max_n_cals(1)
  end

  def problem2() do
    read_input("data/day01.txt")
    |> max_n_cals(3)
  end
end
