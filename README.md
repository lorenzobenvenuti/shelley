# Shelley

A gem for converting your classes and method into a shell supporting nested commands, autocomplete and history.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shelley'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shelley

## Usage

### A simple shell

```ruby
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

command_registry = Shelley::CommandRegistry.new
command_registry.add_command(Calculator.new)
shell = Shelley::InteractiveShell.new(command_registry)
shell.start
```

Sample output

```
> add 3
> result
3
> add 5
> subtract 2
> result
6
> divide_by 3
> result
2
> multiply_by 10
> result
20
> divide_by 0
divided by 0
>
```

### A shell with subcommands

## TODO

* Support for adding single methods
* Automatic argument convertion
* Argument autocomplete
* Refactor `InteractiveShell` and `CommandRegistry` in order to not expose the internal state of `CommandRegistry`
