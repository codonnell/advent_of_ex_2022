defmodule Day11 do
  @total_rounds 10000

  def read_input(f) do
    File.read!(f)
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn s -> String.split(s, "\n") end)
    |> Enum.map(fn lines -> Enum.map(lines, &String.trim/1) end)
    |> Enum.map(fn [
                     "Monkey " <> monkey_n,
                     "Starting items: " <> items,
                     "Operation: new = old " <> operation,
                     "Test: divisible by " <> div_n,
                     "If true: throw to monkey " <> true_monkey,
                     "If false: throw to monkey " <> false_monkey
                   ] ->
      [op, op_n] = String.split(operation)

      op_fn =
        case op do
          "+" ->
            fn old ->
              old +
                case op_n do
                  "old" -> old
                  n -> String.to_integer(n)
                end
            end

          "*" ->
            fn old ->
              old *
                case op_n do
                  "old" -> old
                  n -> String.to_integer(n)
                end
            end
        end

      %{
        monkey: String.to_integer(String.replace(monkey_n, ":", "")),
        items: :queue.from_list(Enum.map(String.split(items, ", "), &String.to_integer/1)),
        op_fn: op_fn,
        test_divisible_by: String.to_integer(div_n),
        if_true_monkey: String.to_integer(true_monkey),
        if_false_monkey: String.to_integer(false_monkey),
        inspections: 0
      }
    end)
    |> Enum.into(%{}, fn x -> {x[:monkey], x} end)
  end

  def step_monkey(monkey_n, state) do
    monkey = state[monkey_n]
    items = :queue.to_list(monkey[:items])

    Enum.reduce(items, state, fn item, state ->
      new_item = div(monkey[:op_fn].(item), 3)

      next_monkey =
        if rem(new_item, monkey[:test_divisible_by]) == 0 do
          monkey[:if_true_monkey]
        else
          monkey[:if_false_monkey]
        end

      state
      |> update_in([next_monkey, :items], fn items -> :queue.in(new_item, items) end)
      |> update_in([monkey_n, :items], &:queue.drop/1)
      |> update_in([monkey_n, :inspections], &(&1 + 1))
    end)
  end

  def step_round(state) do
    Enum.reduce(Enum.sort(Map.keys(state)), state, &step_monkey/2)
  end

  def solve1(f) do
    read_input(f)
    |> Stream.iterate(&step_round/1)
    |> Enum.fetch!(20)
    |> Map.values()
    |> Enum.map(fn monkey -> monkey[:inspections] end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  def step_item({state, monkey_n, item, round}) do
    divisible_by_product =
      state
      |> Map.values()
      |> Enum.map(fn monkey -> monkey[:test_divisible_by] end)
      |> Enum.product()

    monkey = state[monkey_n]

    new_item = rem(monkey[:op_fn].(item), divisible_by_product)

    next_monkey =
      if rem(new_item, monkey[:test_divisible_by]) == 0 do
        monkey[:if_true_monkey]
      else
        monkey[:if_false_monkey]
      end

    # IO.puts("Current monkey: " <> Integer.to_string(monkey_n) <> ", next monkey: " <> Integer.to_string(next_monkey))

    {state, next_monkey, new_item,
     if next_monkey <= monkey_n do
       round + 1
     else
       round
     end}
  end

  def merge_inspections(inspections1, inspections2) do
    Map.merge(inspections1, inspections2, fn _k, v1, v2 -> v1 + v2 end)
  end

  def find_cycle_length({state, monkey_n, item}) do
    {state, monkey_n, item, 1}
    |> Stream.iterate(&step_item/1)
    |> Enum.reduce_while({Map.new(), MapSet.new()}, fn {_state, monkey_n, item, round},
                                                       {m, seen} ->
      if MapSet.member?(seen, {monkey_n, item}) do
        {:halt,
         %{repeat_round: round, start_round: Map.fetch!(m, {monkey_n, item}), all_rounds: m}}
      else
        {:cont, {Map.put(m, {monkey_n, item}, round), MapSet.put(seen, {monkey_n, item})}}
      end
    end)
  end

  def item_inspections(t) do
    %{start_round: start_round, repeat_round: repeat_round, all_rounds: all_rounds} =
      find_cycle_length(t)

    base_inspections =
      all_rounds
      |> Enum.filter(fn {_, round} -> round < start_round end)
      |> Enum.map(fn {{monkey_n, _}, _} -> monkey_n end)
      |> Enum.frequencies()

    cycle_length = repeat_round - start_round
    remaining_rounds = @total_rounds - start_round
    num_cycles = div(remaining_rounds, cycle_length)
    partial_cycle_length = rem(remaining_rounds, cycle_length)

    repeat_inspections =
      all_rounds
      |> Enum.filter(fn {_, round} -> round >= start_round end)
      |> Enum.map(fn {{monkey_n, _}, _} -> monkey_n end)
      |> Enum.frequencies()
      |> Enum.into(%{}, fn {monkey_n, inspections} -> {monkey_n, inspections * num_cycles} end)

    partial_cycle_inspections =
      all_rounds
      |> Enum.filter(fn {_, round} ->
        round >= start_round and round < start_round + partial_cycle_length
      end)
      |> Enum.map(fn {{monkey_n, _}, _} -> monkey_n end)
      |> Enum.frequencies()

    base_inspections
    |> merge_inspections(repeat_inspections)
    |> merge_inspections(partial_cycle_inspections)
  end

  def item_inspections2({state, monkey_n, item}) do
    {state, monkey_n, item, 1}
    |> Stream.iterate(&step_item/1)
    |> Enum.take_while(fn {_, _, _, round} -> round <= @total_rounds end)
    |> Enum.map(fn {_, monkey_n, _, _} -> monkey_n end)
    |> Enum.frequencies()
  end

  def solve2(f) do
    state = read_input(f)
    |> Enum.into(%{}, fn {monkey_n, monkey} ->
      {monkey_n, Map.update!(monkey, :items, &:queue.to_list/1)}
    end)

    state
    |> Enum.flat_map(fn {monkey_n, %{items: items}} ->
      Enum.map(items, fn item -> {state, monkey_n, item} end)
    end)
    |> Enum.map(&item_inspections2/1)
    |> Enum.reduce(&merge_inspections/2)
    |> Map.values()
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end
end
