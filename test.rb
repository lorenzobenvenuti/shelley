require_relative 'lib/shelley'

class Calculator
  def initialize
    @value = 0
  end

  def add(n)
    @value += n.to_i
  end

  def subtract(n)
    @value -= n.to_i
  end

  def multiply_by(n)
    @value *= n.to_i
  end

  def divide_by(n)
    @value /= n.to_i
  end

  def result
    puts @value
  end
end

class Timer
  def initialize
    @started_at = -1
    @elapsed = 0
  end

  def start
    raise 'Already started' if @started_at != -1
    @started_at = Time.now
  end

  def stop
    raise 'Not started' if @started_at == -1
    @elapsed = elapsed
    @started_at = -1
  end

  def elapsed
    @elapsed + Time.now - @started_at
  end
end

command_registry = Shelley::CommandRegistry.new
command_registry.add_command(Calculator.new, 'calc')
command_registry.add_command(Timer.new, 'timer')
shell = Shelley::InteractiveShell.new(command_registry)
shell.start
