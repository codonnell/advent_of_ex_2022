defmodule Day14 do
  def read_input(f) do
    File.read!(f)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s -> String.split(s, " -> ") end)
    |> Enum.map(fn pairs ->
      Enum.map(pairs, fn pair ->
        [x, y] = String.split(pair, ",")
        {String.to_integer(x), String.to_integer(y)}
      end)
    end)
  end

  def generate_rock_line([{x_1, y_1}, {x_2, y_2}]) do
    for x <- x_1..x_2, y <- y_1..y_2 do
      {x, y}
    end
  end

  def generate_rock_structure(pairs) do
    pairs
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&generate_rock_line/1)
    |> Enum.reduce(&Enum.concat/2)
    |> MapSet.new()
  end

  def generate_rock_structures(pairs_coll) do
    pairs_coll
    |> Enum.map(&generate_rock_structure/1)
    |> Enum.reduce(&MapSet.union/2)
    |> Enum.reduce(Map.new(), fn {x, y}, m ->
      Map.update(m, x, [y], fn ys -> [y | ys] end)
    end)
    |> Enum.into(%{}, fn {x, ys} -> {x, Enum.sort(ys)} end)
  end

  def stops_at(ys, y) do
    case ys |> Enum.drop_while(fn y_o -> y >= y_o end) |> List.first(:falls_through) do
      :falls_through -> :falls_through
      stop -> stop - 1
    end
  end

  def drop_sand(%{sand: {x, y}, obstacles: obstacles} = state) do
    column = Map.get(obstacles, x, [])

    next_y = stops_at(column, y)

    new_sand =
      cond do
        next_y == :falls_through ->
          :falls_through

        next_y > y ->
          {x, next_y}

        stops_at(Map.get(obstacles, x - 1, []), y) == :falls_through ->
          :falls_through

        stops_at(Map.get(obstacles, x - 1, []), y) > next_y ->
          {x - 1, stops_at(Map.get(obstacles, x - 1, []), y)}

        stops_at(Map.get(obstacles, x + 1, []), y) == :falls_through ->
          :falls_through

        stops_at(Map.get(obstacles, x + 1, []), y) > next_y ->
          {x + 1, stops_at(Map.get(obstacles, x + 1, []), y)}

        true ->
          {x, y}
      end

    %{state | sand: new_sand}
  end

  def add_sand_as_obstacle(obstacles) do
    %{sand: {500, 0}, obstacles: obstacles}
    |> Stream.iterate(&drop_sand/1)
    |> Stream.chunk_every(2, 1)
    |> Enum.find(fn [%{sand: sand_1}, %{sand: sand_2}] ->
      sand_1 == sand_2 or sand_2 == :falls_through
    end)
    |> then(fn [_, %{sand: sand_2}] ->
      case sand_2 do
        {x, y} -> Map.update(obstacles, x, [y], fn ys -> Enum.sort([y | ys]) end)
        :falls_through -> :falls_through
      end
    end)
  end

  def solve1(f) do
    read_input(f)
    |> generate_rock_structures()
    |> Stream.iterate(&add_sand_as_obstacle/1)
    |> Stream.with_index()
    |> Enum.find(fn {v, _} -> v == :falls_through end)
    |> then(&elem(&1, 1) - 1)
  end

  def add_floor(obstacles) do
    floor_y = obstacles
    |> Map.values()
    |> Enum.reduce(&Enum.concat/2)
    |> Enum.max()
    |> then(& &1 + 2)

    width_from_midpoint = floor_y + 1
    floor_x_coords = (500 - width_from_midpoint)..(500 + width_from_midpoint)

    Enum.reduce(floor_x_coords, obstacles, fn x, obstacles ->
      Map.update(obstacles, x, [floor_y], fn ys -> ys ++ [floor_y] end)
    end)
   end

  def solve2(f) do
    read_input(f)
    |> generate_rock_structures()
    |> add_floor()
    |> Stream.iterate(&add_sand_as_obstacle/1)
    |> Stream.with_index()
    |> Enum.find(fn {obstacles, _} -> List.first(obstacles[500]) == 0 end)
    |> then(&elem(&1, 1))
  end
end
