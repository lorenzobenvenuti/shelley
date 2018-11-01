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
end
