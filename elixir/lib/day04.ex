defmodule Day04 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x ->
      [[start1, end1], [start2, end2]] = x
      |> String.split(",")
      |> Enum.map(fn y ->
        String.split(y, "-") |> Enum.map(&String.to_integer/1)
      end)
      {{start1, end1}, {start2, end2}}
    end)
  end

  def contains?({{start1, end1}, {start2, end2}}) do
    (start1 <= start2 and end1 >= end2) or (start2 <= start1 and end2 >= end1)
  end

  def overlaps?({{start1, end1}, {start2, end2}}) do
    (start1 <= start2 and end1 >= start2) or (start2 <= start1 and end2 >= start1)
  end

  def problem1(input \\ "data/day04.txt", type \\ :file) do
    read_input(input, type)
    |> Enum.count(&contains?/1)
  end

  def problem2(input \\ "data/day04.txt", type \\ :file) do
    read_input(input, type)
    |> Enum.count(&overlaps?/1)
  end
end
