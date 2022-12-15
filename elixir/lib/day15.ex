defmodule Day15 do
  def read_input(input, type \\ :file) do
    Helpers.file_or_io(input, type)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_entry/1)
  end

  def parse_entry(text) do
    [_, sensor_x, sensor_y, beacon_x, beacon_y] =
      Regex.run(~r/^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$/, text)
    {
      {String.to_integer(sensor_x), String.to_integer(sensor_y)},
      {String.to_integer(beacon_x), String.to_integer(beacon_y)}
    }
  end

  def manhattan({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def radius_row_slice({sensor_x, sensor_y}, nearest_beacon, row) do
    radius = manhattan({sensor_x, sensor_y}, nearest_beacon)
    vert_distance = abs(sensor_y - row)
    diff = radius - vert_distance
    cond do
      diff < 0 -> nil
      true -> (sensor_x - diff)..(sensor_x + diff)
    end
  end

  def combine_ranges(ranges) do
    for range <- Enum.sort(ranges), not is_nil(range), reduce: [] do
      acc ->
        case acc do
          [] -> [range]
          [prev | rest] ->
            if Range.disjoint?(prev, range) do
              [range | acc]
            else
              merged = min(range.first, prev.first)..max(range.last, prev.last)
              [merged | rest]
            end
        end
    end
  end

  def find_distress(data, x_range, y_range) do
    row = y_range.first
    slices = data
    |> Enum.map(fn {sensor, beacon} -> radius_row_slice(sensor, beacon, row) end)
    |> Enum.filter(fn slice -> not is_nil(slice) end)
    |> Enum.map(fn range -> max(x_range.first, range.first)..min(x_range.last, range.last) end)
    |> combine_ranges()
    case slices do
      [x_range] ->
        if row != y_range.last, do: find_distress(data, x_range, (row + 1)..y_range.last)
      [r1, r2] ->
        [left, right] = Enum.sort([r1, r2])
        case right.first - left.last do
          2 -> {left.last + 1, row}
        end
    end
  end

  def problem1(row, input \\ "data/day15.txt", type \\ :file) do
    data = read_input(input, type)
    slices = data
    |> Enum.map(fn {sensor, beacon} -> radius_row_slice(sensor, beacon, row) end)
    |> combine_ranges()

    # every beacon in this row will be in some range
    # so just total ranges and subtract beacon count
    slices_size = slices
    |> Enum.map(&Range.size/1)
    |> Enum.sum()
    beacons_in_row = data
    |> Enum.map(fn {_, beacon} -> beacon end)
    |> MapSet.new()
    |> Enum.count(fn {_, beacon_y} -> beacon_y == row end)
    slices_size - beacons_in_row
  end

  def problem2(x_range, y_range, input \\ "data/day15.txt", type \\ :file) do
    data = read_input(input, type)
    {distress_x, distress_y} = find_distress(data, x_range, y_range)
    distress_x * 4000000 + distress_y
  end
end
