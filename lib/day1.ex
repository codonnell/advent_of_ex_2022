defmodule Day1 do
  def read_input(f) do
    File.read!(f)
    |> String.split("\n")
    |> Enum.chunk_by(fn s -> s == "" end)
    |> Enum.filter(fn l -> l != [""] end)
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)
  end

  def solve1(f) do
    read_input(f)
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end

  def solve2(f) do
    read_input(f)
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end
end
