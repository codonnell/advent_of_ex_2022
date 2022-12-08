defmodule Day6 do
  def read_input(f) do
    File.read!(f)
  end

  def solve1(f) do
    read_input(f)
    |> to_charlist()
    |> Enum.chunk_every(4, 1)
    |> Enum.with_index(4)
    |> Enum.filter(fn {v, _i} -> v == Enum.uniq(v) end)
    |> hd()
    |> then(fn {_, i} -> i end)
  end

  def solve2(f) do
    read_input(f)
    |> to_charlist()
    |> Enum.chunk_every(14, 1)
    |> Enum.with_index(14)
    |> Enum.filter(fn {v, _i} -> v == Enum.uniq(v) end)
    |> hd()
    |> then(fn {_, i} -> i end)
  end
end
