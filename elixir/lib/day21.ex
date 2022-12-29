defmodule Day21 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> Map.new()
  end

  def parse_line(line) do
    [id, raw_expr] = String.split(line, ": ")
    expr = try do
      int = String.to_integer(raw_expr)
      {:identity, int}
    rescue ArgumentError ->
      [a, op, b] = String.split(raw_expr, " ")
      op = case op do
        "+" -> :add
        "-" -> :subtract
        "*" -> :multiply
        "/" -> :divide
      end
      {op, a, b}
    end
    {id, expr}
  end

  def dep_graph(monkeys) do
    graph = for {id, expr} <- monkeys, into: %{} do
      deps = case expr do
        {:identity, _} -> []
        {_, a, b} -> [a, b]
      end
      {id, %{parents: deps, children: []}}
    end
    for {id, info} <- graph, parent <- info[:parents], reduce: graph do
      acc -> update_in(acc, [parent, :children], fn children -> [id | children] end)
    end
  end

  def topsort(graph) do
    no_parents = for {k, v} <- graph, length(v[:parents]) == 0, do: k
    topsort(graph, [], no_parents)
  end

  def topsort(graph, list, no_parents) do
    case no_parents do
      [] -> Enum.reverse(list)
      [id | rest] ->
        new_list = [id | list]
        {new_graph, new_no_parents} = for child_id <- graph[id][:children], reduce: {graph, rest} do
          {graph, no_parents} ->
            graph = update_in(graph, [child_id, :parents], fn parents ->
              Enum.filter(parents, fn parent_id -> parent_id != id end)
            end)
            case graph[child_id][:parents] do
              [] -> {graph, [child_id | no_parents]}
              _ -> {graph, no_parents}
            end
        end
        topsort(Map.delete(new_graph, id), new_list, new_no_parents)
    end
  end

  def evaluate_topsorted(monkeys, list, values) do
    case list do
      [] -> values
      [id | rest] ->
        value = case monkeys[id] do
          {:identity, a} -> a
          {:add, a, b} -> values[a] + values[b]
          {:subtract, a, b} -> values[a] - values[b]
          {:multiply, a, b} -> values[a] * values[b]
          {:divide, a, b} -> values[a] / values[b]
        end
        evaluate_topsorted(monkeys, rest, Map.put(values, id, value))
    end
  end

  def evaluate_topsorted_deriv(monkeys, list, values, derivs) do
    case list do
      [] -> derivs
      [id | rest] ->
        deriv = case monkeys[id] do
          {:identity, _} -> if id == "humn", do: 1, else: 0
          {:add, a, b} -> derivs[a] + derivs[b]
          {:subtract, a, b} -> derivs[a] - derivs[b]
          {:multiply, a, b} -> values[a] * derivs[b] + values[b] * derivs[a]
          {:divide, a, b} ->
            (values[b] * derivs[a] - values[a] * derivs[b]) /  (values[b] * values[b])
        end
        evaluate_topsorted_deriv(monkeys, rest, values, Map.put(derivs, id, deriv))
    end
  end

  def newton(monkeys, order, x, n \\ 1) do
    monkeys = Map.put(monkeys, "humn", {:identity, x})
    values = evaluate_topsorted(monkeys, order, %{})
    if values["root"] == 0 or n <= 0 do
      x
    else
      derivs = evaluate_topsorted_deriv(monkeys, order, values, %{})
      next_x = x - trunc(round(values["root"] / derivs["root"]))
      if next_x == x do
        x
      else
        newton(monkeys, order, next_x, n - 1)
      end
    end
  end

  def problem1(input \\ "data/day21.txt", type \\ :file) do
    monkeys = read_input(input, type)
    order = monkeys |> dep_graph() |> topsort()
    evaluate_topsorted(monkeys, order, %{})
    |> Map.get("root")
  end

  def problem2(input \\ "data/day21.txt", type \\ :file) do
    monkeys = read_input(input, type)
    |> Map.update!("root", fn {:add, a, b} -> {:subtract, a, b} end)
    order = monkeys |> dep_graph() |> topsort()
    newton(monkeys, order, 5, 10)
  end
end
