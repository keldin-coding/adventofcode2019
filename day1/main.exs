defmodule Solution do
  def read_file() do
    File.read!("input") |> String.split("\n")
  end

  # Mass calculator. Really finding fuel required for a specific module
  def find_mass(""), do: 0

  def find_mass(str) when is_binary(str) do
    {int, _} = Integer.parse(str)

    find_mass(int)
  end

  def find_mass(num) when is_number(num) do
    val = Integer.floor_div(num, 3) - 2

    cond do
      val >= 0 ->
        val

      true ->
        0
    end
  end

  # Specific, recursive calculator for the weight of fuel
  def calculate_for_fuel(0), do: 0

  def calculate_for_fuel(mass) do
    val = find_mass(mass)

    val + calculate_for_fuel(val)
  end
end

result =
  Solution.read_file()
  |> Enum.reduce(0, fn x, acc ->
    v = Solution.find_mass(x)
    acc + v + Solution.calculate_for_fuel(v)
  end)

IO.inspect(result)
