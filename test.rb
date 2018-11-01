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
    @started_at = nil
    @elapsed = 0
  end

  def start
    return unless @started_at.nil?
    @started_at = Time.now
  end

  def stop
    return if @started_at.nil?
    @elapsed += Time.now - @started_at
    @started_at = nil
  end

  def elapsed
    elapsed = @elapsed
    elapsed += (Time.now - @started_at) unless @started_at.nil?
    puts elapsed
  end
end

command_registry = Shelley::CommandRegistry.new
command_registry.add_command(Calculator.new, 'calc')
command_registry.add_command(Timer.new, 'timer')
shell = Shelley::InteractiveShell.new(command_registry)
shell.start
