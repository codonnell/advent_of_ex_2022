defmodule Day10 do
  @target_cycles MapSet.new([20, 60, 100, 140, 180, 220])

  def parse_command("noop") do
    {:noop}
  end

  def parse_command("addx " <> n) do
    {:addx, String.to_integer(n)}
  end

  def read_input(f) do
    File.read!(f)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_command/1)
  end

  def run_command({:noop}, [state | _] = states) do
    [Map.update!(state, :cycle, &(&1 + 1)) | states]
  end

  def run_command({:addx, n}, [state | _] = states) do
    [
      state
      |> Map.update!(:x, &(&1 + n))
      |> Map.update!(:cycle, &(&1 + 2)),
      Map.update!(state, :cycle, &(&1 + 1))
      | states
    ]
  end

  def solve1(f) do
    read_input(f)
    |> Enum.reduce([%{x: 1, cycle: 1}], &run_command/2)
    |> Enum.reverse()
    |> Enum.filter(fn state -> MapSet.member?(@target_cycles, state[:cycle]) end)
    |> Enum.map(fn %{x: x, cycle: cycle} -> x * cycle end)
    |> Enum.sum()
  end

  def sprite_visible?(%{x: x, cycle: cycle}) do
    pixel_position = rem(cycle - 1, 40)
    pixel_position == x - 1 or pixel_position == x or pixel_position == x + 1
  end

  def solve2(f) do
    read_input(f)
    |> Enum.reduce([%{x: 1, cycle: 1}], &run_command/2)
    |> Enum.reverse()
    |> Enum.map(fn state -> Map.put(state, :visible, sprite_visible?(state)) end)
    |> Enum.take(240)
    |> Enum.map(fn %{visible: visible} ->
      if visible do
        "#"
      else
        "."
      end
    end)
    |> Enum.chunk_every(40)
    |> Enum.each(&IO.puts/1)
  end
end
