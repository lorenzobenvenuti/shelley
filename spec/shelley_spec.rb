RSpec.describe Shelley::CommandNode do
  describe '#ensure_exists' do
    it 'creates a single node' do
      tree = Shelley::CommandNode.new
      tree.ensure_exists('child')
      expect(tree.children.count).to eq(1)
      expect(tree.children[0].name).to eq('child')
    end

    it 'doesn\'t create anything if an empty path is given' do
      tree = Shelley::CommandNode.new
      node = tree.ensure_exists
      expect(node).to eq(tree)
    end

    it 'creates a path' do
      tree = Shelley::CommandNode.new
      tree.ensure_exists('parent', 'child', 'nephew')
      expect(tree.children.count).to eq(1)
      parent = tree.children[0]
      expect(parent.name).to eq('parent')
      expect(parent.children.count).to eq(1)
      child = parent.children[0]
      expect(child.name).to eq('child')
      expect(child.children.count).to eq(1)
      nephew = child.children[0]
      expect(nephew.name).to eq('nephew')
      expect(nephew.children.count).to eq(0)
    end

    it "doesn't recreate a node if it already exists" do
      tree = Shelley::CommandNode.new
      tree.ensure_exists('parent', 'child', 'nephew')
      tree.ensure_exists('parent', 'child', 'another_nephew')
      expect(tree.children.count).to eq(1)
      parent = tree.children[0]
      expect(parent.name).to eq('parent')
      expect(parent.children.count).to eq(1)
      child = parent.children[0]
      expect(child.name).to eq('child')
      expect(child.children.count).to eq(2)
      nephew = child.children[0]
      expect(nephew.name).to eq('nephew')
      expect(nephew.children.count).to eq(0)
      another_nephew = child.children[1]
      expect(another_nephew.name).to eq('another_nephew')
      expect(another_nephew.children.count).to eq(0)
    end
  end

  describe '#node_by_path' do
    before do
      @tree = Shelley::CommandNode.new
      @tree.ensure_exists('parent', 'child', 'nephew')
    end

    it 'should return the node itself if an empty path is given' do
      node = @tree.node_by_path
      expect(node).to eq(@tree)
    end

    it 'should return a node if a path with one element is given' do
      parent = @tree.node_by_path('parent')
      expect(parent.name).to eq('parent')
    end

    it 'should return a node if a path with more elements is given' do
      nephew = @tree.node_by_path('parent', 'child', 'nephew')
      expect(nephew.name).to eq('nephew')
    end

    it 'should return a node if a more elements siblings are present' do
      @tree.ensure_exists('parent', 'child', 'another_nephew')
      another_nephew = @tree.node_by_path('parent', 'child', 'another_nephew')
      expect(another_nephew.name).to eq('another_nephew')
    end

    it 'should return nil for non existing paths' do
      @tree.ensure_exists('parent', 'child', 'another_nephew')
      expect(@tree.node_by_path('foo')).to be_nil
      expect(@tree.node_by_path('parent', 'foo')).to be_nil
      expect(@tree.node_by_path('parent', 'child', 'foo')).to be_nil
      expect(@tree.node_by_path('parent', 'child', 'nephew', 'foo')).to be_nil
    end
  end

  describe '#full_path' do
    before do
      @tree = Shelley::CommandNode.new
    end

    it 'should return an empty list for the root' do
      expect(@tree.full_path).to eq([])
    end

    it 'should return a list for a node with many elements' do
      @tree.ensure_exists('parent', 'child', 'nephew')
      nephew = @tree.node_by_path('parent', 'child', 'nephew')
      expect(nephew.full_path).to eq(%w[parent child nephew])
    end
  end
end

RSpec.describe Shelley::CommandRegistry do
  class TestClass
    attr_reader :x, :y

    def initialize
      @foo_invoked = false
      @x = nil
      @y = nil
    end

    def foo
      @foo_invoked = true
    end

    def foo_invoked?
      @foo_invoked
    end

    def bar(x, y)
      @x = x
      @y = y
    end
  end

  class HelloClass
    def hello; end
  end

  describe '#add_command' do
    it 'can add commands to root' do
      command_registry = Shelley::CommandRegistry.new
      command_registry.add_command(TestClass.new)
      command_registry.execute_command('foo')
      expect(command_registry.command?('foo')).to be true
      expect(command_registry.command?('bar')).to be true
    end

    it 'can add commands as subcommands' do
      command_registry = Shelley::CommandRegistry.new
      command_registry.add_command(TestClass.new, 'cmd')
      expect(command_registry.command?('cmd', 'foo')).to be true
      expect(command_registry.command?('cmd', 'bar')).to be true
    end

    it 'can add commands at nested levels' do
      command_registry = Shelley::CommandRegistry.new
      command_registry.add_command(TestClass.new, 'cmd', 'test')
      command_registry.add_command(HelloClass.new, 'cmd')
      expect(command_registry.command?('cmd', 'test', 'foo')).to be true
      expect(command_registry.command?('cmd', 'test', 'bar')).to be true
      expect(command_registry.command?('cmd', 'hello')).to be true
    end

    it 'can invoke methods without arguments' do
      command_registry = Shelley::CommandRegistry.new
      foobar = TestClass.new
      command_registry.add_command(foobar, 'cmd')
      command_registry.execute_command('cmd foo')
      expect(foobar.foo_invoked?).to be true
    end

    it 'can invoke methods with arguments' do
      command_registry = Shelley::CommandRegistry.new
      foobar = TestClass.new
      command_registry.add_command(foobar, 'cmd')
      command_registry.execute_command('cmd bar 1 2')
      expect(foobar.x).to eq '1'
      expect(foobar.y).to eq '2'
    end

    it 'fails if command does not exist' do
      command_registry = Shelley::CommandRegistry.new
      foobar = TestClass.new
      expect { command_registry.execute_command('hi') }
        .to raise_error(Shelley::CommandError)
    end

    it 'fails if too few arguments are passed' do
      command_registry = Shelley::CommandRegistry.new
      foobar = TestClass.new
      command_registry.add_command(foobar, 'cmd')
      expect { command_registry.execute_command('cmd bar') }
        .to raise_error(Shelley::CommandError)
    end

    it 'fails if too many arguments are passed' do
      command_registry = Shelley::CommandRegistry.new
      foobar = TestClass.new
      command_registry.add_command(foobar, 'cmd')
      expect { command_registry.execute_command('cmd foo 1 2') }
        .to raise_error(Shelley::CommandError)
    end
  end
end

RSpec.describe Shelley::InteractiveShell do
  class TestCommand
    def start; end

    def stop; end
  end

  class AnotherTestCommand
    def hello; end

    def world; end
  end

  it 'autocompletes a command without path' do
    command_registry = Shelley::CommandRegistry.new
    command_registry.add_command(TestCommand.new)
    shell = Shelley::InteractiveShell.new(command_registry)
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
    expect(shell.autocomplete('test s')).to eq(%w[test st])
    expect(shell.autocomplete('test st')).to eq(%w[start stop])
    expect(shell.autocomplete('test sta')).to eq(['test start'])
  end
end
