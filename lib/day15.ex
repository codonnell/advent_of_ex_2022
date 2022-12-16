defmodule Day15 do
  @min_x 0
  @min_y 0

  # @row_y 10
  # @max_x 20
  # @max_y 20

  @row_y 2000000
  @max_x 4000000
  @max_y 4000000

  def read_input(f) do
    File.read!(f)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s ->
      Regex.run(~r/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/, s)
    end)
    |> Enum.map(fn [_, s_x, s_y, b_x, b_y] ->
      %{
        sensor: {String.to_integer(s_x), String.to_integer(s_y)},
        beacon: {String.to_integer(b_x), String.to_integer(b_y)}
      }
    end)
  end

  def compute_distance(%{sensor: {s_x, s_y}, beacon: {b_x, b_y}} = pair) do
    Map.put(pair, :m_distance, abs(s_x - b_x) + abs(s_y - b_y))
  end

  def row_occlusions(%{sensor: {s_x, s_y}, m_distance: d}, y) do
    row_d = abs(y - s_y)

    if row_d > d do
      MapSet.new()
    else
      width_from_midpoint = d - row_d
      Enum.into((s_x - width_from_midpoint)..(s_x + width_from_midpoint), MapSet.new())
    end
  end

  def solve1(f) do
    pairs = read_input(f)

    beacons_on_row =
      pairs
      |> Enum.filter(fn %{beacon: {_, b_y}} -> b_y == @row_y end)
      |> Enum.map(fn %{beacon: beacon} -> beacon end)

    pairs
    |> Enum.map(&compute_distance/1)
    |> Enum.map(fn pair -> row_occlusions(pair, @row_y) end)
    |> Enum.reduce(&Enum.concat/2)
    |> MapSet.new()
    |> MapSet.difference(Enum.into(beacons_on_row, MapSet.new(), fn {b_x, _} -> b_x end))
    |> Enum.count()
  end

  def shell(%{sensor: {s_x, s_y}, m_distance: d}) do
    0..(d + 1)
    |> Enum.flat_map(fn i ->
      [
        {s_x + i, s_y + (d + 1 - i)},
        {s_x + i, s_y - (d + 1 - i)},
        {s_x - i, s_y + (d + 1 - i)},
        {s_x - i, s_y - (d + 1 - i)}
      ]
    end)
    |> Enum.filter(fn {x, y} -> @min_x <= x and x <= @max_x and @min_y <= y and y <= @max_y end)
    |> MapSet.new()
  end

  def occluded?({x, y}, pairs) do
    Enum.find(pairs, :not_occluded, fn %{sensor: {s_x, s_y}, m_distance: d} ->
      abs(s_x - x) + abs(s_y - y) <= d
    end) != :not_occluded
  end

  def solve2(f) do
    pairs = read_input(f) |> Enum.map(&compute_distance/1)

    pairs
    |> Enum.flat_map(fn pair -> shell(pair) end)
    |> Enum.find(fn p -> not occluded?(p, pairs) end)
    |> then(fn {x, y} -> (4000000 * x) + y end)
  end
end
