# frozen_string_literal: true

# A good source of cleanup would be to subclass this for each type of operation
# turning this into a factory. Initialize becomes a factory method with a bunch
# of subclasses of instruction with specialized run methods (no more case) and
# specialized advanced functions
class Instruction
  attr_reader :op, :args, :params, :destination, :instruction_set, :destination_builder

  Param = Struct.new(:slot, :mode)

  OPERATIONS = {
    "01" => [:+, [1, 2]],
    "02" => [:*, [1, 2]],
    "03" => [:input, []],
    "04" => [:output, [1]],
    "05" => [:jump_true, [1, 2]],
    "06" => [:jump_false, [1, 2]],
    "07" => [:<, [1, 2]],
    "08" => [:==, [1, 2]],
    "99" => [:halt, []],
  }

  def initialize(instruction_set)
    @instruction_set = instruction_set

    # Operator is defined by the last two characters
    @op, arg_slots = OPERATIONS.fetch(instruction_set[-2..])

    @params = arg_slots.map.with_index do |slot_position, i|
      Param.new(slot_position, instruction_set[2 - i].to_i)
    end

    @destination_builder = Param.new(arg_slots.length + 1, 1)

    @args = []
  end

  def load_arguments(program)
    @args = params.map do |param|
      program.fetch_arg(param.slot, param.mode)
    end

    @destination = program.fetch_arg(destination_builder.slot, destination_builder.mode)
  end

  def run(program)
    program.halt! if op == :halt

    load_arguments(program)

    case op
    when :+, :* then program.update(destination, args.reduce(op))
    when :input then program.update(destination, program.outputs.last)
    when :jump_true
      if args.first != 0
        program.jump(args[1])
        return 0
      end
    when :jump_false
      if args.first == 0
        program.jump(args[1])
        return 0
      end
    when :<, :==
      if args.first.send(op, args[1])
        program.update(destination, 1)
      else
        program.update(destination, 0)
      end
    when :output
      program.outputs << args.first
      puts args.first
    end

    advance
  end

  def advance
    1 + # operation always requires moving forward
      args.length + # always need to move forward by however many arguments
      (has_destination? ? 1 : 0) # Commands with no destination specified
  end

  def has_destination?
    ![:output, :jump_true, :jump_false].include?(op)
  end
end

class Program
  attr_reader :raw_instructions, :outputs
  attr_accessor :position

  def initialize(raw_instructions)
    @raw_instructions = raw_instructions
    @outputs = [5]
    @position = 0
  end

  def fetch_arg(slot, mode)
    case mode
    when 1 then raw_instructions[position + slot]
    when 0 then raw_instructions[raw_instructions[position + slot]]
    end
  end

  def run
    catch(:halt) do
      loop do
        instruction = process(raw_instructions[position])
        advance_by = instruction.run(self)

        self.position += advance_by
      end
    end

    raw_instructions
  end

  def process(instruction_set)
    Instruction.new(instruction_set.to_s.rjust(5, "0"))
  end

  def update(destination, value)
    raw_instructions[destination] = value
  end

  def jump(new_position)
    self.position = new_position
  end

  def halt!
    throw :halt
  end
end

input = File.read("input").strip.split(',').map(&:to_i)

program = Program.new(input)
final = program.run
