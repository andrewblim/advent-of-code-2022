defmodule Day25 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
  end

  def snafu_to_decimal(snafu) do
    snafu
    |> String.replace("2", "4")
    |> String.replace("1", "3")
    |> String.replace("0", "2")
    |> String.replace("-", "1")
    |> String.replace("=", "0")
    |> String.to_integer(5)
    |> reduce_back()
  end

  def reduce_back(x) do
    if x < 5 do
      x - 2
    else
      5 * reduce_back(Integer.floor_div(x, 5)) + rem(x, 5) - 2
    end
  end

  def decimal_to_snafu(dec) do
    Integer.to_string(dec, 5)
    |> String.reverse()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> base5_digits_to_snafu()
    |> Enum.map(fn x ->
      case x do
        -2 -> "="
        -1 -> "-"
        x -> Integer.to_string(x)
      end
    end)
    |> Enum.join()
  end

  def base5_digits_to_snafu(x, carry \\ 0, list \\ []) do
    case x do
      [] ->
        if carry == 0, do: list, else: [carry | list]
      [x | rest] ->
        {new_x, new_carry} = cond do
          x + carry <= 2 -> {x + carry, 0}
          true -> {x + carry - 5, 1}
        end
        base5_digits_to_snafu(rest, new_carry, [new_x | list])
    end
  end

  def compute_console(input) do
    input
    |> Enum.map(&snafu_to_decimal/1)
    |> Enum.sum()
    |> decimal_to_snafu()
  end

  def problem1(input \\ "data/day25.txt", type \\ :file) do
    read_input(input, type)
    |> compute_console()
  end
end
