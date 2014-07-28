libdir = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'nodespec/version'

Gem::Specification.new do |gem|
  gem.name          = 'nodespec'
  gem.version       = NodeSpec::VERSION
  gem.summary       = 'RSpec style tests for multiple nodes/server instances with support for provisioning instructions'
  gem.description   = 'RSpec style tests for multiple nodes/server instances with support for provisioning instructions'
  
  gem.authors       = ['Silvio Montanari']
  gem.homepage      = 'https://github.com/smontanari/nodespec'
  gem.license       = 'MIT'
  
  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_runtime_dependency 'net-ssh'
  gem.add_runtime_dependency 'serverspec'
  gem.add_runtime_dependency 'specinfra', '>= 1.18.4'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'aws-sdk'
  gem.add_development_dependency 'winrm'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
end
