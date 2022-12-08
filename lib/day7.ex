defmodule Day7 do
  def chunk_fun("$" <> _ = command, acc) do
    if Enum.empty?(acc) do
      {:cont, [command]}
    else
      {:cont, Enum.reverse(acc), [command]}
    end
  end

  def chunk_fun(command, acc) do
    {:cont, [command | acc]}
  end

  def read_input(f) do
    File.read!(f)
    |> String.split("\n")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.chunk_while([], &chunk_fun/2, fn acc -> {:cont, Enum.reverse(acc), :ok} end)
  end

  def parse_file("dir " <> dir) do
    %{type: :directory, name: dir, size: 0}
  end

  def parse_file(file) do
    [_, size_str, name] = Regex.run(~r/(\d+) (.+)/, file)
    %{type: :file, name: name, size: String.to_integer(size_str)}
  end

  def run_command(["$ cd /"], state) do
    %{state | work_dir: []}
  end

  def run_command(["$ cd .."], %{work_dir: [_ | parents]} = state) do
    %{state | work_dir: parents}
  end

  def run_command(["$ cd " <> dir], %{work_dir: work_dir} = state) do
    %{state | work_dir: [dir | work_dir]}
  end

  def run_command(["$ ls" | files], %{work_dir: work_dir} = state) do
    parsed_files = Enum.map(files, &parse_file/1)
    put_in(state, [:file_system, work_dir], parsed_files)
  end

  def build_file_system(terminal_output) do
    Enum.reduce(terminal_output, %{work_dir: [], file_system: %{}}, &run_command/2)[:file_system]
  end

  def unnested_sizes(file_system) do
    Enum.into(file_system, %{}, fn {dir, files} ->
      {dir, Enum.map(files, fn f -> f[:size] end) |> Enum.sum()}
    end)
  end

  def nested_sizes(file_system) do
    base_sizes = unnested_sizes(file_system)

    parent_to_children =
      Enum.into(Map.keys(file_system), %{}, fn parent_dir ->
        {parent_dir,
         Enum.filter(Map.keys(file_system), fn dir ->
           List.starts_with?(Enum.reverse(dir), Enum.reverse(parent_dir))
         end)}
      end)

    Enum.into(base_sizes, %{}, fn {dir, _} ->
      {dir,
       Map.fetch!(parent_to_children, dir)
       |> Enum.map(fn child_dir -> Map.fetch!(base_sizes, child_dir) end)
       |> Enum.sum()}
    end)
  end

  def solve1(f) do
    read_input(f)
    |> build_file_system()
    |> nested_sizes()
    |> Map.values()
    |> Enum.filter(fn size -> size <= 100000 end)
    |> Enum.sum()
  end

  def solve2(f) do
    file_system = build_file_system(read_input(f))
    space_used = unnested_sizes(file_system) |> Map.values() |> Enum.sum()
    space_remaining = 70000000 - space_used
    min_deletion_size = 30000000 - space_remaining
    file_system
    |> nested_sizes()
    |> Map.values()
    |> Enum.sort()
    |> Enum.find(fn size -> size >= min_deletion_size end)
  end
end
