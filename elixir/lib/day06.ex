defmodule Day06 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
  end

  def packet_start(input, chunk_size) do
    i = input
    |> String.codepoints()
    |> Stream.chunk_every(chunk_size, 1)
    |> Enum.find_index(fn x -> (length Enum.uniq(x)) == chunk_size end)
    chunk_size + i
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
