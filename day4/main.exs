defmodule Solution do
  def input() do
    172_930..683_082 |> Enum.map(fn x -> x |> Integer.to_string() |> String.codepoints() end)
  end

  def valid_password?(v) do
    adjacent_matches?(v) && never_decreasing?(v)
  end

  def valid_password_parttwo?(v) do
    never_decreasing?(v) && non_repeating_matches?(v)
  end

  def non_repeating_matches?(v) do
    do_non_repeating_matches(v, "", false)
  end

  defp do_non_repeating_matches([_, _ | _tail], "", true), do: true
  defp do_non_repeating_matches([_last], _, true), do: true
  defp do_non_repeating_matches([_last], _, false), do: false

  defp do_non_repeating_matches([one, two | tail], previous, check) do
    cond do
      one == two && two == previous ->
        do_non_repeating_matches([two | tail], previous, false)

      one == two ->
        do_non_repeating_matches([two | tail], two, true)

      # fall through case for non matches
      true ->
        do_non_repeating_matches([two | tail], "", check)
    end
  end

  # Takes in a list of characters that are numbers
  def adjacent_matches?(nums) do
    do_adjacent_matches(nums, false)
  end

  defp do_adjacent_matches([one, two | tail], false) do
    do_adjacent_matches([two | tail], one == two)
  end

  defp do_adjacent_matches(_, true), do: true
  defp do_adjacent_matches(_, false), do: false

  def never_decreasing?(nums) do
    do_never_decreasing(nums, true)
  end

  defp do_never_decreasing([one, two | tail], true) do
    do_never_decreasing([two | tail], two >= one)
  end

  defp do_never_decreasing(_, false), do: false
  defp do_never_decreasing([_last], true), do: true
end

val =
  Solution.input()
  |> Enum.count(&Solution.valid_password_parttwo?(&1))

IO.puts("Valid passwords: #{val}")

# IO.puts(Solution.valid_password_parttwo?(["1", "1", "2", "2", "3", "3"]))
