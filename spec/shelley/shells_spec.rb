RSpec.describe Shelley::InteractiveShell do
  class TestCommand
    def start; end

    def stop; end

    def reset; end
  end

  class AnotherTestCommand
    def hello; end

    def world; end
  end

  it 'autocompletes a command without path' do
    command_registry = Shelley::CommandRegistry.new
    command_registry.add_command(TestCommand.new)
    shell = Shelley::InteractiveShell.new(command_registry)
    expect(shell.autocomplete('')).to eq(%w[reset start stop])
    expect(shell.autocomplete('s')).to eq(%w[start stop])
    expect(shell.autocomplete('sta')).to eq(['start'])
  end

  it 'autocompletes a command' do
    command_registry = Shelley::CommandRegistry.new
    command_registry.add_command(TestCommand.new, 'test')
    shell = Shelley::InteractiveShell.new(command_registry)
    expect(shell.autocomplete('t')).to eq(['test'])
  end

  it 'autocompletes a subcommand' do
    command_registry = Shelley::CommandRegistry.new
    command_registry.add_command(TestCommand.new, 'test')
    shell = Shelley::InteractiveShell.new(command_registry)
    expect(shell.autocomplete('t')).to eq(['test'])
    expect(shell.autocomplete('test')).to eq(%w[reset start stop])
    expect(shell.autocomplete('test st')).to eq(%w[start stop])
    expect(shell.autocomplete('test sta')).to eq(['start'])
  end
end
