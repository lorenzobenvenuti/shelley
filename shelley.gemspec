
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shelley/version'

Gem::Specification.new do |spec|
  spec.name          = 'shelley'
  spec.version       = Shelley::VERSION
  spec.authors       = ['Lorenzo Benvenuti']
  spec.email         = ['lorenzo.benvenuti@gmail.com']

  spec.summary       = 'Convert your ruby code into a shell'
  spec.description   = 'Shelley allows to convert your classes and method into a shell supporting nested commands, autocomplete and history.'
  spec.homepage      = 'https://github.com/lorenzobenvenuti/shelley'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end