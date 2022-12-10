defmodule Day9 do
  def read_input(f) do
    File.read!(f)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [direction, count] -> {direction, String.to_integer(count)} end)
  end

  def direction_to_dp("U"), do: {0, 1}
  def direction_to_dp("D"), do: {0, -1}
  def direction_to_dp("R"), do: {1, 0}
  def direction_to_dp("L"), do: {-1, 0}

  def neighbors({x, y}) do
    MapSet.new(for dx <- [-1, 0, 1], dy <- [-1, 0, 1], do: {x + dx, y + dy})
  end

  def adjust_tail({head_x, head_y} = head, {tail_x, tail_y} = tail) do
    if MapSet.member?(neighbors(head), tail) do
      tail
    else
      {tail_x +
         if head_x == tail_x do
           0
         else
           div(head_x - tail_x, abs(head_x - tail_x))
         end,
       tail_y +
         if head_y == tail_y do
           0
         else
           div(head_y - tail_y, abs(head_y - tail_y))
         end}
    end
  end

  def move(
        direction,
        [[{head_x, head_y} | _] | tails] = paths
      ) do
    {dx, dy} = direction_to_dp(direction)
    new_head = {head_x + dx, head_y + dy}

    new_positions =
      Enum.reduce(tails, [new_head], fn [tail | _], [head | _] = acc ->
        [adjust_tail(head, tail) | acc]
      end)
      |> Enum.reverse()

    Enum.zip_reduce([new_positions, paths], [], fn [position, path], acc ->
      [[position | path] | acc]
    end)
    |> Enum.reverse()
  end

  def solve1(f) do
    read_input(f)
    |> Enum.flat_map(fn {direction, count} -> Enum.take(Stream.cycle([direction]), count) end)
    |> Enum.reduce([[{0, 0}], [{0, 0}]], &move/2)
    |> Enum.fetch!(1)
    |> MapSet.new()
    |> MapSet.size()
  end

  def solve2(f) do
    read_input(f)
    |> Enum.flat_map(fn {direction, count} -> Enum.take(Stream.cycle([direction]), count) end)
    |> Enum.reduce(Enum.map(1..10, fn _ -> [{0,0}] end), &move/2)
    |> Enum.fetch!(9)
    |> MapSet.new()
    |> MapSet.size()
  end
end
