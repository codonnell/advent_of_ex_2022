defmodule Day12 do
  def char_elevation(c) do
    case c do
      ?S -> 0
      ?E -> 25
      c -> c - ?a
    end
  end

  def read_input(f) do
    File.read!(f)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
    |> Stream.with_index()
    |> Enum.flat_map(fn {cs, y} ->
      cs |> Stream.with_index() |> Enum.map(fn {c, x} -> {{x, y}, c} end)
    end)
    |> Enum.into(%{})
  end

  def neighbors({x, y}) do
    MapSet.new([{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}])
  end

  def create_path_digraph(elevations) do
    Enum.into(elevations, %{}, fn {p, elevation} ->
      {p,
       Enum.filter(neighbors(p), fn p_n ->
         Map.has_key?(elevations, p_n) and Map.fetch!(elevations, p_n) <= elevation + 1
       end)}
    end)
  end

  def shortest_path_length(g, starts, finish) do
    starting_q =
      Enum.reduce(starts, PriorityQueue.new(), fn start, q -> PriorityQueue.put(q, {0, start}) end)

    {starting_q, MapSet.new()}
    |> Stream.iterate(fn {q, visited} ->
      {{path_length, p}, new_q} = PriorityQueue.pop!(q)

      if MapSet.member?(visited, p) do
        {new_q, visited}
      else
        {Map.fetch!(g, p)
         |> Enum.reject(fn p_n -> MapSet.member?(visited, p_n) end)
         |> Enum.reduce(new_q, fn p_n, q ->
           PriorityQueue.put(q, {path_length + 1, p_n})
         end), MapSet.put(visited, p)}
      end
    end)
    |> Stream.map(&elem(&1, 0))
    |> Stream.drop_while(fn q ->
      {_, p} = PriorityQueue.min!(q)
      p != finish
    end)
    |> Enum.take(1)
    |> then(fn [q | _] ->
      {path_length, _} = PriorityQueue.min!(q)
      path_length
    end)
  end

  def solve1(f) do
    map = read_input(f)
    start = Enum.find(map, fn {_p, c} -> c == ?S end) |> elem(0)
    finish = Enum.find(map, fn {_p, c} -> c == ?E end) |> elem(0)

    map
    |> Enum.into(%{}, fn {p, c} -> {p, char_elevation(c)} end)
    |> create_path_digraph()
    |> shortest_path_length([start], finish)
  end

  def solve2(f) do
    map = read_input(f)
    finish = Enum.find(map, fn {_p, c} -> c == ?E end) |> elem(0)

    elevations = Enum.into(map, %{}, fn {p, c} -> {p, char_elevation(c)} end)
    starts = elevations |> Enum.filter(fn {_p, n} -> n == 0 end) |> Enum.map(&elem(&1, 0))

    elevations
    |> create_path_digraph()
    |> shortest_path_length(starts, finish)
  end
end
