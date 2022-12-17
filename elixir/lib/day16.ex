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

  def zero_flow?(system) do
    system |> Enum.all?(fn {_, {flow, _}} -> flow == 0 end)
  end

  def max_flow(system, valve, t, visited \\ MapSet.new()) do
    cond do
      t <= 0 -> 0
      zero_flow?(system) -> 0
      true ->
        {flow, neighbors} = system[valve]

        # possible actions:
        # - open valve (if nonzero flow)
        # - move to neighbor (if not already visited)

        visited = MapSet.put(visited, valve)
        moves = for neighbor <- neighbors, not MapSet.member?(visited, neighbor), into: [] do
          max_flow(system, neighbor, t - 1, visited)
        end
        open_valve = if flow > 0 do
          new_system = Map.put(system, valve, {0, neighbors})
          added_flow = flow * (t - 1)
          [added_flow + max_flow(new_system, valve, t - 1)]
        else
          []
        end
        actions = open_valve ++ moves
        case actions do
          [] -> 0
          actions -> Enum.max(actions)
        end
    end
  end

  def problem1(input \\ "data/day16.txt", type \\ :file) do
    read_input(input, type)
    |> max_flow("AA", 30)
  end

  def problem2(input \\ "data/day15.txt", type \\ :file) do
    read_input(input, type)
  end
end
