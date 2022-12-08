defmodule Day08 do
  def read_input(input, type \\ :file) do
    rows = Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    for {row, x} <- Enum.with_index(rows),
        {tree, y} <- Enum.with_index(String.codepoints(row)), into: %{} do
      {{x, y}, String.to_integer(tree)}
    end
  end

  def visible(trees) do
    {max_x, max_y} = trees |> Map.keys() |> Enum.max()
    visible_from_top(trees, {max_x, max_y})
    |> MapSet.union(visible_from_bottom(trees, {max_x, max_y}))
    |> MapSet.union(visible_from_left(trees, {max_x, max_y}))
    |> MapSet.union(visible_from_right(trees, {max_x, max_y}))
  end

  def visible_from_top(trees, {max_x, max_y}) do
    for y <- 0..max_y, reduce: MapSet.new() do
      visible ->
        {_, cur_visible} = for x <- 0..max_x, reduce: {-1, MapSet.new()} do
          {highest, cur_visible} ->
            if trees[{x, y}] > highest do
              {trees[{x, y}], MapSet.put(cur_visible, {x, y})}
            else
              {highest, cur_visible}
            end
        end
        MapSet.union(visible, cur_visible)
    end
  end

  def visible_from_bottom(trees, {max_x, max_y}) do
    for y <- 0..max_y, reduce: MapSet.new() do
      visible ->
        {_, cur_visible} = for x <- max_x..0, reduce: {-1, MapSet.new()} do
          {highest, cur_visible} ->
            if trees[{x, y}] > highest do
              {trees[{x, y}], MapSet.put(cur_visible, {x, y})}
            else
              {highest, cur_visible}
            end
        end
        MapSet.union(visible, cur_visible)
    end
  end

  def visible_from_left(trees, {max_x, max_y}) do
    for x <- 0..max_x, reduce: MapSet.new() do
      visible ->
        {_, cur_visible} = for y <- 0..max_y, reduce: {-1, MapSet.new()} do
          {highest, cur_visible} ->
            if trees[{x, y}] > highest do
              {trees[{x, y}], MapSet.put(cur_visible, {x, y})}
            else
              {highest, cur_visible}
            end
        end
        MapSet.union(visible, cur_visible)
    end
  end

  def visible_from_right(trees, {max_x, max_y}) do
    for x <- 0..max_x, reduce: MapSet.new() do
      visible ->
        {_, cur_visible} = for y <- max_y..0, reduce: {-1, MapSet.new()} do
          {highest, cur_visible} ->
            if trees[{x, y}] > highest do
              {trees[{x, y}], MapSet.put(cur_visible, {x, y})}
            else
              {highest, cur_visible}
            end
        end
        MapSet.union(visible, cur_visible)
    end
  end

  def scores(trees) do
    {max_x, max_y} = trees |> Map.keys() |> Enum.max()
    up_scores(trees, {max_x, max_y})
    |> Map.merge(down_scores(trees, {max_x, max_y}), fn _k, v1, v2 -> v1 * v2 end)
    |> Map.merge(left_scores(trees, {max_x, max_y}), fn _k, v1, v2 -> v1 * v2 end)
    |> Map.merge(right_scores(trees, {max_x, max_y}), fn _k, v1, v2 -> v1 * v2 end)
  end

  def up_scores(trees, {max_x, max_y}) do
    for x <- 0..max_x, y <- 0..max_y, reduce: Map.new() do
      scores ->
        score = cond do
          x == 0 -> 0
          true ->
            1 + Enum.find_index((x - 1)..0, fn x1 -> x1 == 0 or trees[{x, y}] <= trees[{x1, y}] end)
        end
        Map.put(scores, {x, y}, score)
    end
  end

  def down_scores(trees, {max_x, max_y}) do
    for x <- max_x..0, y <- 0..max_y, reduce: Map.new() do
      scores ->
        score = cond do
          x == max_x -> 0
          true ->
            1 + Enum.find_index((x + 1)..max_x, fn x1 -> x1 == max_x or trees[{x, y}] <= trees[{x1, y}] end)
        end
        Map.put(scores, {x, y}, score)
    end
  end

  def left_scores(trees, {max_x, max_y}) do
    for y <- 0..max_y, x <- 0..max_x, reduce: Map.new() do
      scores ->
        score = cond do
          y == 0 -> 0
          true ->
            1 + Enum.find_index((y - 1)..0, fn y1 -> y1 == 0 or trees[{x, y}] <= trees[{x, y1}] end)
        end
        Map.put(scores, {x, y}, score)
    end
  end

  def right_scores(trees, {max_x, max_y}) do
    for y <- max_y..0, x <- 0..max_x, reduce: Map.new() do
      scores ->
        score = cond do
          y == max_y -> 0
          true ->
            1 + Enum.find_index((y + 1)..max_y, fn y1 -> y1 == max_y or trees[{x, y}] <= trees[{x, y1}] end)
        end
        Map.put(scores, {x, y}, score)
    end
  end

  def problem1(input \\ "data/day08.txt", type \\ :file) do
    read_input(input, type)
    |> visible()
    |> MapSet.size()
  end

  def problem2(input \\ "data/day08.txt", type \\ :file) do
    read_input(input, type)
    |> scores()
    |> Map.values()
    |> Enum.max()
  end
end
