defmodule Day07 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.split("$ ", trim: true)
    |> Enum.map(fn x -> x |> String.split("\n", trim: true) end)
  end

  def parse_command_and_output(cmd_and_output, {cwd, fs}) do
    case cmd_and_output do
      ["cd /"] -> {"/", fs}
      ["cd " <> x] -> {Path.expand(Path.join(cwd, x)), fs}
      ["ls" | output] ->
        for item <- output, reduce: {cwd, fs} do
          {cwd, fs} -> parse_ls_item(item, {cwd, fs})
        end
    end
  end

  def parse_ls_item(item, {cwd, fs}) do
    [dir_or_size, name] = String.split(item)
    path = Path.split(Path.join(cwd, name))
    contents = case dir_or_size do
      "dir" -> %{}
      size_str -> String.to_integer(size_str)
    end
    {cwd, put_in(fs, path, contents)}
  end

  def dir_sizes(fs, prefix, matches) do
    {size, matches} = for {name, contents} <- fs, reduce: {0, matches} do
      {size, matches} ->
        if is_integer(contents) do
          {size + contents, matches}
        else
          {dir_size, matches} = dir_sizes(contents, Path.join(prefix, name), matches)
          {size + dir_size, matches}
        end
    end
    matches = Map.put(matches, prefix, size)
    {size, matches}
  end

  def total_small_dir_size(sizes) do
    for {_, size} <- sizes, size <= 100000, reduce: 0 do
      acc -> acc + size
    end
  end

  def find_smallest_deletable(sizes) do
    free_space = 70000000 - sizes["/"]
    needed_space = 30000000 - free_space
    for {_, size} <- sizes, size >= needed_space, reduce: 70000000 do
      acc -> min(acc, size)
    end
  end

  def problem1(input \\ "data/day07.txt", type \\ :file) do
    items = read_input(input, type)
    {_, fs} = for item <- items, reduce: {"/", %{"/" => %{}}} do
      {cwd, fs} ->
        parse_command_and_output(item, {cwd, fs})
    end
    {_, sizes} = dir_sizes(fs, "/", %{})
    total_small_dir_size(sizes)
  end

  def problem2(input \\ "data/day07.txt", type \\ :file) do
    items = read_input(input, type)
    {_, fs} = for item <- items, reduce: {"/", %{"/" => %{}}} do
      {cwd, fs} ->
        parse_command_and_output(item, {cwd, fs})
    end
    {_, sizes} = dir_sizes(fs, "/", %{})
    find_smallest_deletable(sizes)
  end
end
