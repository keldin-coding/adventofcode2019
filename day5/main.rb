# frozen_string_literal: true

class Instruction
  def self.arg_count; 2; end
  def self.uses_destination?; true; end

  attr_reader :args, :destination

  def initialize(args, destination)
    @args = args
    @destination = destination
  end

  def advance
    1 + # instruction always counts
      self.class.arg_count +
      (self.class.uses_destination? ? 1 : 0)
  end
end

class AddInstruction < Instruction
  def run(program)
    program.update(destination, args.reduce(:+))
    advance
  end
end

class MultiplyInstruction < Instruction
  def run(program)
    program.update(destination, args.reduce(:*))
    advance
  end
end

class HaltInstruction < Instruction
  def self.arg_count; 0; end
  def self.uses_destination?; false; end

  def run(program)
    program.halt!
  end
end

class InputInstruction < Instruction
  def self.arg_count; 0; end

  def run(program)
    program.update(destination, program.outputs.last)
    advance
  end
end

class OutputInstruction < Instruction
  def self.arg_count; 1; end
  def self.uses_destination?; false; end

  def run(program)
    program.outputs << args.first
    puts args.first
    advance
  end
end

class JumpTrueInstruction < Instruction
  def self.uses_destination?; false; end

  def run(program)
    if args[0] != 0
      program.jump(args[1])
      return 0
    else
      advance
    end
  end
end

class JumpFalseInstruction < Instruction
  def self.uses_destination?; false; end

  def run(program)
    if args[0] == 0
      program.jump(args[1])
      return 0
    else
      advance
    end
  end
end

class LessThanInstruction < Instruction
  def run(program)
    val = args[0] < args[1] ? 1 : 0

    program.update(destination, val)
    advance
  end
end

class EqualsInstruction < Instruction
  def run(program)
    val = args[0] == args[1] ? 1 : 0

    program.update(destination, val)
    advance
  end
end

class InstructionFactory
  OPERATIONS = {
    "01" => AddInstruction, # [:+, [1, 2]],
    "02" => MultiplyInstruction, # [:*, [1, 2]],
    "03" => InputInstruction, # [:input, []],
    "04" => OutputInstruction, # [:output, [1]],
    "05" => JumpTrueInstruction, # [:jump_true, [1, 2]],
    "06" => JumpFalseInstruction, # [:jump_false, [1, 2]],
    "07" => LessThanInstruction, # [:<, [1, 2]],
    "08" => EqualsInstruction, # [:==, [1, 2]],
    "99" => HaltInstruction, # [:halt, []],
  }

  def self.build(instruction_set, program)
    klass = OPERATIONS.fetch(instruction_set[-2..])
    destination = nil

    args = (0...klass.arg_count).map do |slot|
      mode = instruction_set[2 - slot].to_i

      program.fetch_arg(slot + 1, mode)
    end

    if klass.uses_destination?
      # The mode for destinations is always 1
      destination = program.fetch_arg(klass.arg_count + 1, 1)
    end

    klass.new(args, destination)
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
    InstructionFactory.build(instruction_set.to_s.rjust(5, "0"), self)
  end

  def fetch_arg(slot, mode)
    case mode
    when 1 then raw_instructions[position + slot]
    when 0 then raw_instructions[raw_instructions[position + slot]]
    end
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
