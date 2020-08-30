defmodule Solution do
  def input() do
    File.read!("input")
    |> String.split(",")
    |> Enum.map(fn x ->
      {num, _} = Integer.parse(x)
      num
    end)
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
  end

  def operate(list, [99 | _rest]), do: {:halt, list}

  def operate(list, [1, source, addend, destination | _rest]) do
    first = Enum.at(list, source)
    second = Enum.at(list, addend)

    {:add, List.replace_at(list, destination, first + second)}
  end

  def operate(list, [2, source, multiplier, destination | _rest]) do
    first = Enum.at(list, source)
    second = Enum.at(list, multiplier)

    {:multiply, List.replace_at(list, destination, first * second)}
  end

  def move_through_list(root_list, working_position) do
    working_set = Enum.slice(root_list, working_position..(working_position + 3))

    case operate(root_list, working_set) do
      {:halt, new_list} ->
        new_list

      {:add, new_list} ->
        move_through_list(new_list, working_position + 4)

      {:multiply, new_list} ->
        move_through_list(new_list, working_position + 4)
    end
  end

  def listen(goal) do
    receive do
      {^goal, noun, verb} ->
        IO.inspect("Noun #{noun} : Verb #{verb}")
        exit(:normal)

      {_, _, _} ->
        listen(goal)
    end
  end
end

goal = 19_690_720

input_list = Solution.input()

result = Solution.move_through_list(input_list, 0)

IO.inspect(result)

# Spin up an actor who can listen for all the other processes to complete.
# Another way to do this may be to create a supervisor that spawns all the
# processes, but this seemed fine for our purposes.
listener = spawn(fn -> Solution.listen(goal) end)

# Brute force through concurrency!
Enum.each(0..99, fn i ->
  Enum.each(0..99, fn j ->
    spawn(fn ->
      result =
        input_list
        |> List.replace_at(1, i)
        |> List.replace_at(2, j)
        |> Solution.move_through_list(0)

      [sum | _tail] = result
      send(listener, {sum, i, j})
    end)
  end)
end)
