defmodule Day05 do
  def read_input(input, type \\ :file) do
    [stacks, moves] = Helpers.file_or_io(input, type)
    |> String.split("\n\n")
    {parse_stacks(stacks), parse_moves(moves)}
  end

  def parse_stacks(input) do
    [labels_input | boxes_input] = input
    |> String.split("\n")
    |> Enum.reverse()
    labels = labels_input |> String.split()
    n_labels = length labels
    boxes = boxes_input
    |> Enum.map(fn line ->
      line
      |> String.pad_trailing(n_labels * 4)
      |> String.codepoints()
      |> Enum.chunk_every(4)
      |> Enum.map(fn [_, x, _, _] -> x end)
    end)
    {labels, boxes}
  end

  def parse_moves(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, n, from, to] = Regex.run(~r/^move (\d+) from (\d+) to (\d+)$/, line)
      {String.to_integer(n), from, to}
    end)
  end

  def initial_stacks(labels, boxes) do
    stacks = for label <- labels, into: %{} do
      {label, []}
    end
    for row <- boxes, {label, box} <- Enum.zip(labels, row), box != " ", reduce: stacks do
      acc -> %{acc | label => [box | acc[label]]}
    end
  end

  def make_move(stacks, {n, from, to}) do
    move = stacks[from] |> Enum.take(n) |> Enum.reverse()
    %{stacks | from => Enum.drop(stacks[from], n), to => move ++ stacks[to]}
  end

  def make_moves(stacks, moves) do
    for {n, from, to} <- moves, reduce: stacks do
      acc -> make_move(acc, {n, from, to})
    end
  end

  def make_move2(stacks, {n, from, to}) do
    move = stacks[from] |> Enum.take(n)
    %{stacks | from => Enum.drop(stacks[from], n), to => move ++ stacks[to]}
  end

  def make_moves2(stacks, moves) do
    for {n, from, to} <- moves, reduce: stacks do
      acc -> make_move2(acc, {n, from, to})
    end
  end

  def read_tops(stacks) do
    # assume consistent ordering of labels
    for {_, stack} <- stacks, into: "" do
      hd(stack)
    end
  end

  def problem1(input \\ "data/day05.txt", type \\ :file) do
    {{labels, boxes}, moves} = read_input(input, type)
    initial_stacks(labels, boxes)
    |> make_moves(moves)
    |> read_tops()
  end

  def problem2(input \\ "data/day05.txt", type \\ :file) do
    {{labels, boxes}, moves} = read_input(input, type)
    initial_stacks(labels, boxes)
    |> make_moves2(moves)
    |> read_tops()
  end
end
