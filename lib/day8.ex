defmodule Day8 do
  def read_input(f) do
    File.read!(f)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(fn row ->
      Enum.into(Enum.map(row, &String.to_integer/1), PersistentVector.new())
    end)
    |> Enum.into(PersistentVector.new())
  end

  def is_visible?(grid, {i, j}) do
    if i == 0 or j == 0 or i == PersistentVector.count(grid) - 1 or
         j == PersistentVector.count(grid[0]) - 1 do
      true
    else
      above = Enum.map(0..(i - 1), &grid[&1][j])
      below = Enum.map((i + 1)..(PersistentVector.count(grid) - 1), &grid[&1][j])
      left = Enum.map(0..(j - 1), &grid[i][&1])
      right = Enum.map((j + 1)..(PersistentVector.count(grid[0]) - 1), &grid[i][&1])
      x = grid[i][j]

      Enum.all?(above, &(&1 < x)) or
        Enum.all?(below, &(&1 < x)) or
        Enum.all?(left, &(&1 < x)) or
        Enum.all?(right, &(&1 < x))
    end
  end

  def solve1(f) do
    grid = read_input(f)

    cells =
      Enum.flat_map(0..(PersistentVector.count(grid) - 1), fn i ->
        Enum.map(0..(PersistentVector.count(grid[0]) - 1), fn j -> {i, j} end)
      end)

    Enum.filter(cells, &is_visible?(grid, &1))
    |> Enum.count()
  end

  def get_visible_cells(line_of_sight, x) do
    {shorter, rest} = Enum.split_while(line_of_sight, &(&1 < x))
    if Enum.empty?(rest) do
      shorter
    else
      shorter ++ [hd(rest)]
    end
  end

  def scenic_score(grid, {i, j}) do
    if i == 0 or j == 0 or i == PersistentVector.count(grid) - 1 or
         j == PersistentVector.count(grid[0]) - 1 do
      0
    else
      x = grid[i][j]
      above = Enum.map((i - 1)..0, &grid[&1][j]) |> get_visible_cells(x)
      below = Enum.map((i + 1)..(PersistentVector.count(grid) - 1), &grid[&1][j]) |> get_visible_cells(x)
      left = Enum.map((j - 1)..0, &grid[i][&1]) |> get_visible_cells(x)
      right = Enum.map((j + 1)..(PersistentVector.count(grid[0]) - 1), &grid[i][&1]) |> get_visible_cells(x)

      [above, below, left, right]
      |> Enum.map(&Enum.count/1)
      |> Enum.product()
    end
  end

  def solve2(f) do
    grid = read_input(f)

    cells =
      Enum.flat_map(0..(PersistentVector.count(grid) - 1), fn i ->
        Enum.map(0..(PersistentVector.count(grid[0]) - 1), fn j -> {i, j} end)
      end)

    Enum.map(cells, &scenic_score(grid, &1))
    |> Enum.max()
  end
end
