defmodule Solution do
  def input() do
    inputs = File.read!("input")
    |> String.split("\n")
    |> Enum.map(&(String.split(&1, ",")))
    [first, second | _] = inputs

    [first, second]
  end

  # This and the map_path/3 functions should be broken apart. In particular,
  # all the map_path/3 functions share the creating a new map section, just
  # differing in iterating over the x or y axis and what the range is. Pattern
  # matching could probably get that to a do_map_path/4 where the first and
  # second elements are the x and y ranges, with guard clauses to check if one
  # is an integer. So one to iterate over x and one to iterate over y depending
  # on if one of the ranges given is actually just a number.
  def build_map(directions) do
    Enum.reduce(directions, {%{}, {0, 0, 0}}, fn d, acc ->
      {path, coords} = acc
      {x, y, steps} = coords

      case map_path(d, coords, path) do
        {:right, val, new_path} ->
          {new_path, {x + val, y, steps + val}}
        {:left, val, new_path} ->
          {new_path, {x - val, y, steps + val}}
        {:up, val, new_path} ->
          {new_path, {x, y + val, steps + val}}
        {:down, val, new_path} ->
          {new_path, {x, y - val, steps + val}}
      end
    end)
  end

  def map_path("R" <> movement, start, path) do
    {value, _} = Integer.parse(movement)

    {x, y, steps} = start

    {new_map, _count} = Enum.reduce((x + 1)..(x + value), {path, steps}, fn iter, acc ->
      {old_map, steps_so_far} = acc

      new_map = Map.put(old_map, {iter, y}, {1, steps_so_far + 1})
      {new_map, steps_so_far + 1}
    end)

    {:right, value, new_map}
  end

  def map_path("L" <> movement, start, path) do
    {value, _} = Integer.parse(movement)

    {x, y, steps} = start

    {new_map, _count} = Enum.reduce((x-1)..(x-value), {path, steps}, fn iter, acc ->
      {old_map, steps_so_far} = acc

      new_map = Map.put(old_map, {iter, y}, {1, steps_so_far + 1})
      {new_map, steps_so_far + 1}
    end)

    {:left, value, new_map}
  end

  def map_path("U" <> movement, start, path) do
    {value, _} = Integer.parse(movement)

    {x, y, steps} = start

    {new_map, _count} = Enum.reduce((y + 1)..(y + value), {path, steps}, fn iter, acc ->
      {old_map, steps_so_far} = acc

      new_map = Map.put(old_map, {x, iter}, {1, steps_so_far + 1})
      {new_map, steps_so_far + 1}
    end)

    {:up, value, new_map}
  end

  def map_path("D" <> movement, start, path) do
    {value, _} = Integer.parse(movement)

    {x, y, steps} = start

    {new_map, _count} = Enum.reduce((y - 1)..(y - value), {path, steps}, fn iter, acc ->
      {old_map, steps_so_far} = acc

      new_map = Map.put(old_map, {x, iter}, {1, steps_so_far + 1})
      {new_map, steps_so_far + 1}
    end)

    {:down, value, new_map}
  end
end

lists = Solution.input()

[first_wire, second_wire] = Enum.map(lists, fn l ->
  {path, _} = Solution.build_map(l)

  path
end)

IO.inspect(first_wire)
IO.inspect(second_wire)

merged = Map.merge(first_wire, second_wire, fn _, value1, value2 ->
  {_, count1} = value1
  {_, count2} = value2

  {2, count1 + count2}
end)

IO.inspect(merged)

crosses = Map.to_list(merged) |> Enum.filter(
  fn {k, v} ->
    {touches, _steps} = v
    k != {0, 0} && touches == 2
  end
)

# IO.inspect(crosses)

dist = Enum.min_by(crosses, fn {_coord, values} ->
  {_, steps} = values
  steps
end)

IO.inspect(dist)

# distance = fn {x, y} -> abs(0 - x) + abs(0 - y) end
# dist = Enum.min_by(crosses, distance)

# IO.inspect(distance.(dist))
