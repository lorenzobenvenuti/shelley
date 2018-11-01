module Shelley
  # An interactive shell, supporting history and autocompletion
  class InteractiveShell
    attr_accessor :prompt

    def initialize(command_registry)
      @command_registry = command_registry
      @prompt = '> '
    end

    # Retrieves candidate nodes for a given path
    def candidate_nodes(*path)
      return @command_registry.commands_tree.children if path.count.zero?
      last_name = path.pop
      node = @command_registry.commands_tree.node_by_path(*path)
      return [] if node.nil?
      last_node = node.node_by_path(last_name)
      return last_node.children unless last_node.nil?
      node.children.select { |n| n.name =~ /^#{Regexp.escape(last_name)}/ }
    end

    # Tries to autocomplete a lines
    def autocomplete(line)
      candidate_nodes(*line.split).map(&:name).sort
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
