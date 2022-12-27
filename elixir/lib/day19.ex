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

  def score_blueprints(blueprints, n) do
    for blueprint <- blueprints, into: %{} do
      init_state = %{
        resources: %{ore: 0, clay: 0, obs: 0, geode: 0},
        robots: %{ore: 1, clay: 0, obs: 0, geode: 0},
      }
      final_states = bfs(blueprint, MapSet.new([init_state]), n)
      max_geodes = final_states
      |> Enum.map(fn state -> state[:resources][:geode] end)
      |> Enum.max()
      {blueprint[:id], {MapSet.size(final_states), max_geodes}}
    end
  end

  def bfs(blueprint, states, n) do
    if n <= 0 do
      states
    else
      next_no_build_states = for state <- states, do: {state, %{}}
      next_build_states =
        for state <- states,
            robot_type <- [:ore, :clay, :obs, :geode],
            {built_state, construction} = build(blueprint, state, robot_type),
            valid_state?(built_state) do
          {built_state, construction}
        end
      next_states = next_no_build_states ++ next_build_states
      |> Enum.map(fn {state, construction} -> produce(state, construction) end)
      bfs(blueprint, MapSet.new(next_states), n - 1)
    end
  end

  def valid_state?(state) do
    state[:resources][:ore] >= 0 and state[:resources][:clay] >= 0 and state[:resources][:obs] >= 0
  end

  def build(blueprint, state, robot_type) do
    next_state = state
    |> update_in([:resources, :ore], fn x -> x - blueprint[robot_type][:ore] end)
    |> update_in([:resources, :clay], fn x -> x - blueprint[robot_type][:clay] end)
    |> update_in([:resources, :obs], fn x -> x - blueprint[robot_type][:obs] end)
    {next_state, %{robot_type => 1}}
  end

  def produce(state, construction) do
    state
    |> update_in([:resources, :ore], fn x -> x + state[:robots][:ore] end)
    |> update_in([:resources, :clay], fn x -> x + state[:robots][:clay] end)
    |> update_in([:resources, :obs], fn x -> x + state[:robots][:obs] end)
    |> update_in([:resources, :geode], fn x -> x + state[:robots][:geode] end)
    |> update_in([:robots, :ore], fn x -> x + Map.get(construction, :ore, 0) end)
    |> update_in([:robots, :clay], fn x -> x + Map.get(construction, :clay, 0) end)
    |> update_in([:robots, :obs], fn x -> x + Map.get(construction, :obs, 0) end)
    |> update_in([:robots, :geode], fn x -> x + Map.get(construction, :geode, 0) end)
  end

  def problem1(input \\ "data/day19.txt", type \\ :file) do
    read_input(input, type)
    |> score_blueprints(19)
  end

  def problem2(input \\ "data/day19.txt", type \\ :file) do
    read_input(input, type)
  end
end
