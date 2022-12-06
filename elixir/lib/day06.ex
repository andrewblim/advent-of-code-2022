defmodule Day06 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
  end

  def packet_start(input, chunk_size) do
    input
    |> String.codepoints()
    |> Enum.chunk_every(chunk_size, 1)
    |> Enum.with_index(chunk_size)
    |> Enum.drop_while(fn {x, _} -> (length Enum.uniq(x)) != chunk_size end)
    |> hd()
    |> elem(1)
  end

  def problem1(input \\ "data/day06.txt", type \\ :file) do
    read_input(input, type)
    |> packet_start(4)
  end

  def problem2(input \\ "data/day06.txt", type \\ :file) do
    read_input(input, type)
    |> packet_start(14)
  end
end
