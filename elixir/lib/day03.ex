defmodule Day03 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
  end

  def split_rucksack(contents) do
    String.split_at(contents, div(String.length(contents), 2))
    |> Tuple.to_list()
  end

  def shared_items(compartments) do
    compartments
    |> Enum.map(fn x -> MapSet.new(String.codepoints(x)) end)
    |> Enum.reduce(fn x, acc -> MapSet.intersection(x, acc) end)
  end

  def item_valuation(item) do
    String.to_charlist(item)
    |> Enum.map(fn x ->
      if x < 97 do
        x - 64 + 26
      else
        x - 96
      end
    end)
    |> Enum.sum
  end

  def value_shared_items(contents) do
    contents
    |> shared_items()
    |> Enum.map(&item_valuation/1)
    |> Enum.sum()
  end

  def problem1(input \\ "data/day03.txt", type \\ :file) do
    read_input(input, type)
    |> Enum.map(&split_rucksack/1)
    |> Enum.map(&value_shared_items/1)
    |> Enum.sum()
  end

  def problem2(input \\ "data/day03.txt", type \\ :file) do
    read_input(input, type)
    |> Enum.chunk_every(3)
    |> Enum.map(&value_shared_items/1)
    |> Enum.sum()
  end
end
