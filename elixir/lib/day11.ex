defmodule Day11 do
  def read_input(input, type \\ :file) do
    monkeys = Helpers.file_or_io(input, type)
    |> String.split("\n\n")
    |> Enum.map(&parse_monkey/1)
    {monkey_map, monkey_order} = for monkey <- monkeys, reduce: {%{}, []} do
      {monkey_map, monkey_order} ->
        {Map.put(monkey_map, monkey[:id], monkey), [monkey[:id] | monkey_order]}
    end
    {monkey_map, Enum.reverse(monkey_order)}
  end

  def parse_monkey(input) do
    input = input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)

    case input do
      [
        "Monkey " <> id,
        "Starting items: " <> items,
        "Operation: new = " <> transform,
        "Test: divisible by " <> divisor,
        "If true: throw to monkey " <> true_throw,
        "If false: throw to monkey " <> false_throw
      ] ->
        %{
          id: id |> String.slice(0..-2),  # remove ":"
          items: items |> String.split(", ") |> Enum.map(&String.to_integer/1),
          transform: String.split(transform, " ") |> Enum.map(fn x ->
            case x do
              "+" -> "+"
              "*" -> "*"
              "old" -> "old"
              x -> String.to_integer(x)
            end
          end),
          divisor: String.to_integer(divisor),
          true_throw: true_throw,
          false_throw: false_throw,
        }
    end
  end

  def lcm(a, b) do
    Integer.floor_div(a * b, gcd(a, b))
  end

  def gcd(a, b) do
    case b do
      0 -> a
      _ -> gcd(b, rem(a, b))
    end
  end

  def gcd([x | tail]) do
    case tail do
      [] -> x
      [y | tail] ->
        gcd([gcd(max(x, y), min(x, y)) | tail])
    end
  end

  def lcm(x) do
    Integer.floor_div(Enum.product(x), gcd(x))
  end

  def run_rounds(monkeys, order, div_by_3, times \\ 1) do
    divisor_lcm = monkeys |> Map.values() |> Enum.map(fn x -> x[:divisor] end) |> lcm()
    for _ <- 1..times, id <- order, reduce: {monkeys, %{}} do
      {monkeys, inspections} ->
        will_inspect = length(monkeys[id][:items])
        {
          run_monkey(monkeys, id, div_by_3, divisor_lcm),
          Map.update(inspections, id, will_inspect, fn x -> x + will_inspect end)
        }
    end
  end

  def sub_old(x, old) do
    case x do
      "old" -> old
      _ -> x
    end
  end

  def run_monkey(monkeys, id, div_by_3, divisor_lcm) do
    active = monkeys[id]
    monkeys = for item <- monkeys[id][:items], reduce: monkeys do
      acc ->
        new_item = case active[:transform] do
          [x, "+", y] -> sub_old(x, item) + sub_old(y, item)
          [x, "*", y] -> sub_old(x, item) * sub_old(y, item)
        end
        new_item = if div_by_3, do: Integer.floor_div(new_item, 3), else: new_item
        target = case rem(new_item, active[:divisor]) do
          0 -> active[:true_throw]
          _ -> active[:false_throw]
        end
        Map.update!(acc, target, fn monkey ->
          Map.put(monkey, :items, monkey[:items] ++ [rem(new_item, divisor_lcm)])
        end)
    end
    Map.update!(monkeys, id, fn monkey -> Map.put(monkey, :items, []) end)
  end

  def problem1(input \\ "data/day11.txt", type \\ :file) do
    {monkeys, order} = read_input(input, type)
    {_, inspections} = run_rounds(monkeys, order, true, 20)
    Map.values(inspections) |> Enum.sort(:desc) |> Enum.take(2) |> Enum.product()
  end

  def problem2(input \\ "data/day11.txt", type \\ :file) do
    {monkeys, order} = read_input(input, type)
    {_, inspections} = run_rounds(monkeys, order, false, 10000)
    Map.values(inspections) |> Enum.sort(:desc) |> Enum.take(2) |> Enum.product()
  end
end
