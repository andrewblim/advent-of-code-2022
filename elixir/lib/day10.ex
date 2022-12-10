defmodule Day10 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x ->
      case x do
        "noop" -> [:noop]
        "addx " <> x -> [:addx, String.to_integer(x)]
      end
    end)
  end

  def execute({instructions, register, elapsed}, max_steps) do
    if max_steps <= 0 do
      {instructions, register, elapsed}
    else
      case instructions do
        [] -> {[], register, elapsed}
        [[:noop] | rest] ->
          execute({rest, register, 0}, max_steps - 1)
        [[:addx, x] | rest] ->
          if elapsed < 1 do
            execute({instructions, register, elapsed + 1}, max_steps - 1)
          else
            execute({rest, register + x, 0}, max_steps - 1)
          end
      end
    end
  end

  def problem1(input \\ "data/day10.txt", type \\ :file) do
    instructions = read_input(input, type)
    {_, _, signals} = for n <- [19, 59, 99, 139, 179, 219], reduce: {{instructions, 1, 0}, 0, []} do
      {state, prev_n, signals} ->
        new_state = execute(state, n - prev_n)
        {new_state, n, [(n + 1) * elem(new_state, 1) | signals]}
    end
    Enum.sum(signals)
  end

  def problem2(input \\ "data/day10.txt", type \\ :file) do
    instructions = read_input(input, type)
    {_, picture} = for n <- 1..240, reduce: {{instructions, 1, 0}, []} do
      {state, picture} ->
        horiz = rem(n - 1, 40)
        register = elem(state, 1)
        pixel = if abs(horiz - register) <= 1, do: "#", else: "."
        new_state = execute(state, 1)
        {new_state, [pixel | picture]}
    end
    picture
    |> Enum.reverse()
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end
end
