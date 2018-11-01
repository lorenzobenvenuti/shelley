require 'readline'
require 'shelley/version'

module Shelley
  # A node of the command tree
  class CommandNode
    attr_reader :children, :parent
    attr_accessor :name
    attr_accessor :command

    def initialize(parent = nil)
      @children = []
      @parent = parent
    end

    def ensure_exists(*path)
      return self if path.count.zero?
      curr_name = path.shift
      node = @children.find { |n| n.name == curr_name }
      if node.nil?
        node = CommandNode.new(self)
        node.name = curr_name
        @children << node
      end
      return node if path.count.zero?
      node.ensure_exists(*path)
    end

    def node_by_path(*path)
      return self if path.count.zero?
      curr_name = path.shift
      node = @children.find { |n| n.name == curr_name }
      return nil if node.nil?
      return node if path.count.zero?
      node.node_by_path(*path)
    end

    def full_path
      curr_node = self
      path = []
      until curr_node.parent.nil?
        path << curr_node.name
        curr_node = curr_node.parent
      end
      path.reverse
    end

    def to_s
      "CommandNode(name=#{name}, command=#{command}, children={#{children.map(&:to_s)}})"
    end
  end

  # A command
  class Command
    def initialize(method)
      @method = method
    end

    def execute(*args)
      @method.call(*args)
    rescue StandardError => msg
      raise CommandError, msg
    end
  end

  # An error raised by the CommandRegistry if a command fails
  class CommandError < StandardError
  end

  # A shell
  class CommandRegistry
    def initialize
      @tree = CommandNode.new
    end

    # Returns the command tree
    def commands_tree
      @tree
    end

    def command?(*path)
      !@tree.node_by_path(*path).nil?
    end

    # Adds a command to the shell
    def add_command(instance, *path)
      node = @tree.ensure_exists(*path)
      instance.class.public_instance_methods(false).each do |method_name|
        child = node.ensure_exists(method_name.to_s)
        child.command = Command.new(instance.method(method_name))
      end
    end

    def raise_error(command)
      raise CommandError, "Cannot find command \"#{command}\""
    end

    # Executes a command
    def execute_command(command)
      tokens = command.split
      node = @tree
      until tokens.count.zero?
        prev_node = node
        curr_name = tokens.shift
        node = node.node_by_path(curr_name)
        if node.nil?
          raise_error(command) if prev_node.command.nil?
          tokens.insert(0, curr_name)
          prev_node.command.execute(*tokens)
          return
        elsif tokens.count.zero?
          node.command.execute
          return
        end
      end
      raise_error(command)
    end
  end

  # An interactive shell, supporting history and autocompletion
  class InteractiveShell
    attr_accessor :prompt

    def initialize(command_registry)
      @command_registry = command_registry
      @prompt = '> '
    end

    # Tries to autocomplete a lines
    def autocomplete(line)
      path = line.split
      return @command_registry.commands_tree.children if path.count.zero?
      last_name = path.pop
      node = @command_registry.commands_tree.node_by_path(*path)
      return [] if node.nil?
      last_node = node.node_by_path(last_name)
      return last_node.children unless last_node.nil?
      node.children.select { |n| n.name =~ /^#{Regexp.escape(last_name)}/ }
          .map(&:name).sort
    end

    # Starts the shell
    def start
      Readline.completion_append_character = ' '
      Readline.completion_proc = lambda do |_line|
        autocomplete(Readline.line_buffer)
      end
      while (line = Readline.readline(@prompt, true))
        begin
          @command_registry.execute_command(line)
        rescue StandardError => msg
          puts msg
        end
      end
    end
  end

  # A non-interactive shell. Executes given commands sequentially
  class NonInteractiveShell
    def initialize(command_registry, commands)
      @command_registry = command_registry
      @commands = commands
    end

    # Starts the shell
    def start
      @commands.each do |command|
        begin
          puts "> #{command}"
          @command_registry.execute_command(command)
        rescue StandardError => msg
          puts msg
        end
      end
    end
  end
end
