defmodule Day13 do
  def read_input(f) do
    File.read!(f)
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn s -> String.split(s, "\n") end)
    |> Enum.map(fn vs -> Enum.map(vs, fn v -> elem(Code.eval_string(v), 0) end) end)
  end

  def aoc_compare([x1 | r1], [x2 | r2]) do
    x_comp = aoc_compare(x1, x2)
    case x_comp do
      :eq -> aoc_compare(r1, r2)
      v -> v
    end
  end

  def aoc_compare([_ | _], []) do
    :gt
  end

  def aoc_compare([], [_ | _]) do
    :lt
  end

  def aoc_compare([_x1 | _r1] = c1, x2) when is_integer(x2) do
    aoc_compare(c1, [x2])
  end

  def aoc_compare(x1, [_x2 | _r2] = c2) when is_integer(x1) do
    aoc_compare([x1], c2)
  end

  def aoc_compare([], x2) when is_integer(x2) do
    :lt
  end

  def aoc_compare(x1, []) when is_integer(x1) do
    :gt
  end

  def aoc_compare([], []) do
    :eq
  end

  def aoc_compare(x1, x2) when is_integer(x1) and is_integer(x2) do
    cond do
      x1 > x2 -> :gt
      x2 > x1 -> :lt
      x1 == x2 -> :eq
    end
  end

  def sorter(v1, v2) do
    case aoc_compare(v1, v2) do
      :gt -> false
      _ -> true
    end
  end

  def solve1(f) do
    read_input(f)
    |> Enum.with_index(1)
    |> Enum.map(fn {[v1, v2], index} -> {aoc_compare(v1, v2), index} end)
    |> Enum.filter(fn {c, _} -> c == :lt end)
    |> Enum.map(& elem(&1, 1))
    |> Enum.sum()
  end

  def solve2(f) do
    read_input(f)
    |> Enum.concat()
    |> then(fn vs -> [[[2]], [[6]] | vs] end)
    |> Enum.sort(&sorter/2)
    |> Enum.with_index(1)
    |> Enum.filter(fn {v, _} -> v == [[2]] or v == [[6]] end)
    |> Enum.map(& elem(&1, 1))
    |> Enum.product()
  end
end
