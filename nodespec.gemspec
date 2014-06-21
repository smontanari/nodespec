libdir = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'nodespec/version'

Gem::Specification.new do |gem|
  gem.name          = 'nodespec'
  gem.version       = NodeSpec::VERSION
  gem.summary       = 'RSpec tests on multiple node/server instances with provisioning'
  gem.description   = <<-eos
This gem sits on top of Serverspec and features:
  - Ability to test multiple servers with different os and backends.
  - Ability to run provisioning instructions (chef, puppet, shell) as part of the test setup.
  eos
  
  gem.authors       = ['Silvio Montanari']
  gem.email         = 'montanari.silvio@gmail.com'
  gem.files         = `git ls-files`.split($/)
  gem.files         = Dir['lib/*']
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'rspec'
  gem.add_runtime_dependency 'net-ssh'
  gem.add_runtime_dependency 'serverspec'
  gem.add_runtime_dependency 'specinfra'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
end