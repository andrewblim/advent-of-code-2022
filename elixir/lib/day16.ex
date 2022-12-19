defmodule Day16 do
  def read_input(input, type \\ :file) do
    rows = Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    for row <- rows, {valve, flow, neighbors} = parse_entry(row), into: %{} do
      {valve, {flow, neighbors}}
    end
  end

  def parse_entry(text) do
    [_, valve, flow, neighbors] =
      Regex.run(~r/^Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)$/, text)
    {
      valve,
      String.to_integer(flow),
      String.split(neighbors, ", ")
    }
  end

  def shortest_paths(system, valves, visited \\ %{}, depth \\ 0) do
    visited = for valve <- valves, into: visited, do: {valve, depth}
    next_valves = for valve <- valves,
                      neighbor <- elem(system[valve], 1),
                      not Map.has_key?(visited, neighbor) do
      neighbor
    end
    case next_valves do
      [] -> visited
      _ -> shortest_paths(system, next_valves, visited, depth + 1)
    end
  end

  def shortest_paths_memo(system) do
    for valve <- Map.keys(system), into: %{} do
      {valve, shortest_paths(system, [valve])}
    end
  end

  def max_flow(system, valve, t, paths_memo) do
    # consider all movements to unopened valves where we could open the valve
    # and score points in time
    for {next_valve, depth} <- paths_memo[valve],
        elem(system[next_valve], 0) > 0,
        t - depth - 1 >= 0,
        reduce: 0 do
      acc ->
        {flow, neighbors} = system[next_valve]
        added_flow = flow * (t - depth - 1)
        new_system = Map.put(system, next_valve, {0, neighbors})
        recur_flow = max_flow(new_system, next_valve, t - depth - 1, paths_memo)
        max(acc, added_flow + recur_flow)
    end
  end

  def max_flow2(system, valve1, valve2, t1, t2, paths_memo) do
    for {next_valve1, depth1} <- paths_memo[valve1],
        {next_valve2, depth2} <- paths_memo[valve2],
        next_valve1 != next_valve2,
        elem(system[next_valve1], 0) > 0,
        elem(system[next_valve2], 0) > 0,
        next_t1 = t1 - depth1 - 1,
        next_t2 = t2 - depth2 - 1,
        next_t1 >= 0 or next_t2 >= 0,
        reduce: 0 do
      acc ->
        {flow1, neighbors1} = system[next_valve1]
        {flow2, neighbors2} = system[next_valve2]
        added_flow1 = flow1 * max(next_t1, 0)
        added_flow2 = flow2 * max(next_t2, 0)
        added_flow = added_flow1 + added_flow2
        new_system = system
        |> Map.put(next_valve1, {0, neighbors1})
        |> Map.put(next_valve2, {0, neighbors2})
        recur_flow = cond do
          next_t2 < 0 -> max_flow(new_system, next_valve1, t1, paths_memo)
          next_t1 < 0 -> max_flow(new_system, next_valve2, t2, paths_memo)
          true -> max_flow2(new_system, next_valve1, next_valve2, next_t1, next_t2, paths_memo)
        end
        # recur_flow = max_flow2(new_system, next_valve1, next_valve2, next_t1, next_t2, paths_memo)
        max(acc, added_flow + recur_flow)
    end
  end

  def problem1(input \\ "data/day16.txt", type \\ :file) do
    system = read_input(input, type)
    paths_memo = shortest_paths_memo(system)
    max_flow(system, "AA", 30, paths_memo)
  end

  def problem2(input \\ "data/day16.txt", type \\ :file) do
    system = read_input(input, type)
    paths_memo = shortest_paths_memo(system)
    max_flow2(system, "AA", "AA", 26, 26, paths_memo)
  end
end
