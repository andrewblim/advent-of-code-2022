defmodule Day19 do
  def read_input(input, type \\ :file) do
    input = if type == :io do
      input
      |> String.replace("\n  ", "\n")
      |> String.replace("\n", " ")
      |> String.replace("  Blueprint", "\nBlueprint")
    else
      input
    end

    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  def parse_line(row) do
    matches =
      Regex.run(
        ~r/^Blueprint (\d+): Each ore robot costs (\d)+ ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian.$/,
        row,
        capture: :all_but_first
      )
    [id, ore_cost, clay_cost, obs_ore_cost, obs_clay_cost, geode_ore_cost, geode_obs_cost] =
      Enum.map(matches, &String.to_integer/1)
    %{
      id: id,
      ore: %{ore: ore_cost, clay: 0, obs: 0, geode: 0},
      clay: %{ore: clay_cost, clay: 0, obs: 0, geode: 0},
      obs: %{ore: obs_ore_cost, clay: obs_clay_cost, obs: 0, geode: 0},
      geode: %{ore: geode_ore_cost, clay: 0, obs: geode_obs_cost, geode: 0}
    }
  end

  def augment_blueprint(blueprint) do
    max_costs = for resource_type <- [:ore, :clay, :obs, :geode], into: %{} do
      max_cost = [:ore, :clay, :obs, :geode]
      |> Enum.map(fn robot_type -> blueprint[robot_type][resource_type] end)
      |> Enum.max()
      {resource_type, max_cost}
    end
    Map.put(blueprint, :max_costs, max_costs)
  end

  def score_blueprints(blueprints, n) do
    init_state = %{
      resources: %{ore: 0, clay: 0, obs: 0, geode: 0},
      robots: %{ore: 1, clay: 0, obs: 0, geode: 0},
      turns_left: n,
    }
    for blueprint <- blueprints, into: %{} do
      blueprint = augment_blueprint(blueprint)
      visited = bfs(blueprint, MapSet.new([init_state]), MapSet.new())
      final_scores = Enum.map(visited, &score_state/1)
      {blueprint[:id], Enum.max(final_scores)}
    end
  end

  def score_blueprints2(blueprints, n) do
    init_state = %{
      resources: %{ore: 0, clay: 0, obs: 0, geode: 0},
      robots: %{ore: 1, clay: 0, obs: 0, geode: 0},
      turns_left: 0,
    }
    for blueprint <- blueprints, into: %{} do
      blueprint = augment_blueprint(blueprint)
      states = MapSet.new([init_state])
      final_states = for _ <- 1..n, reduce: states do
        prev_states ->
          prev_states = for state <- prev_states, into: MapSet.new() do
            Map.update!(state, :turns_left, fn prev_n -> prev_n + 1 end)
          end
          next_states = bfs(blueprint, prev_states, MapSet.new())
          max_geodes = next_states
          |> Enum.map(fn state -> state[:resources][:geode] end)
          |> Enum.max()
          next_states |> Enum.filter(fn state -> state[:resources][:geode] >= max_geodes - 3 end)
      end
      final_scores = Enum.map(final_states, &score_state/1)
      {blueprint[:id], Enum.max(final_scores)}
    end
  end

  def bfs(blueprint, states, visited) do
    # IO.inspect(MapSet.size(visited))
    if MapSet.size(states) == 0 do
      visited
    else
      visited = MapSet.union(visited, states)
      next_states =
        for state <- states,
            next_robot_type <- [:ore, :clay, :obs, :geode],
            not is_nil(state[:resources][next_robot_type]),
            build_state = build(blueprint, state, next_robot_type),
            not is_nil(build_state),
            not MapSet.member?(visited, build_state),
            into: MapSet.new() do
          build_state
        end
      bfs(blueprint, next_states, visited)
    end
  end

  def score_state(state) do
    produce(state, state[:turns_left])[:resources][:geode]
  end

  def build(blueprint, state, robot_type) do
    t = time_to_build(blueprint, state, robot_type)
    if not is_nil(t) and t < state[:turns_left] do
      # produce for t turns
      # then pay for the robot and build it
      state = state
      |> produce(t)
      |> update_in([:resources, :ore], fn x ->
        if not is_nil(x), do: x - blueprint[robot_type][:ore]
      end)
      |> update_in([:resources, :clay], fn x ->
        if not is_nil(x), do: x - blueprint[robot_type][:clay]
      end)
      |> update_in([:resources, :obs], fn x ->
        if not is_nil(x), do: x - blueprint[robot_type][:obs]
      end)
      |> produce()
      |> update_in([:robots, robot_type], fn x -> x + 1 end)

      # figure out when we don't need to track robots/resources any more
      if must_track?(blueprint, state, robot_type) do
        state
      else
        state
        |> put_in([:robots, robot_type], nil)
        |> put_in([:resources, robot_type], nil)
      end
    end
  end

  def must_track?(blueprint, state, resource_type) do
    # we must track a resource if we could spend more than we have now or if the rate of production
    # is less than we could spend on a given turn
    resource_type == :geode
    or blueprint[:max_costs][resource_type] > state[:resources][resource_type]
    or blueprint[:max_costs][resource_type] > state[:robots][resource_type]
  end

  def time_to_build(blueprint, state, robot_type) do
    # Time it will take to gain enough resources to build a certain robot
    # nil -> not possible; zero robots of a necessary resource
    for resource_type <- [:ore, :clay, :obs, :geode],
        cost = blueprint[robot_type][resource_type],
        resources = state[:resources][resource_type],
        robots = state[:robots][resource_type],
        reduce: 0 do
      acc ->
        cond do
          is_nil(acc) -> nil
          cost == 0 -> acc
          robots == 0 -> nil
          true -> max(acc, ceil_div(cost - resources, robots))
        end
    end
  end

  def ceil_div(x, y) do
    Integer.floor_div(x - 1, y) + 1
  end

  def produce(state, n \\ 1) do
    state
    |> update_in([:resources, :ore], fn x ->
      if not is_nil(x), do: x + state[:robots][:ore] * n
    end)
    |> update_in([:resources, :clay], fn x ->
      if not is_nil(x), do: x + state[:robots][:clay] * n
    end)
    |> update_in([:resources, :obs], fn x ->
      if not is_nil(x), do: x + state[:robots][:obs] * n
    end)
    |> update_in([:resources, :geode], fn x -> x + state[:robots][:geode] * n end)
    |> update_in([:turns_left], fn prev_n -> prev_n - n end)
  end

  def problem1(input \\ "data/day19.txt", type \\ :file) do
    read_input(input, type)
    |> score_blueprints(24)
    |> Enum.reduce(0, fn {id, score}, acc -> acc + id * score end)
  end

  def problem2(input \\ "data/day19.txt", type \\ :file) do
    read_input(input, type)
    |> Enum.take(3)
    |> score_blueprints2(32)
  end
end
