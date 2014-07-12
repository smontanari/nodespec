libdir = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'nodespec/version'

Gem::Specification.new do |gem|
  gem.name          = 'nodespec'
  gem.version       = NodeSpec::VERSION
  gem.summary       = 'RSpec style tests for multiple nodes/server instances with support for provisioning instructions'
  gem.description   = <<-eos
This gem sits on top of Serverspec and features:
  - Supports different os types (Windows/UN*X) and backends (SSH, WinRM) at the same time.
  - Supports multiple containers (Vagrant, Amazon EC2)
  - Ability to run provisioning instructions (chef, puppet, ansible, shell) as part of the test setup.
  eos
  
  gem.authors       = ['Silvio Montanari']
  gem.email         = 'montanari.silvio@gmail.com'
  gem.files         = `git ls-files`.split($/)
  gem.files         = Dir['lib/*']
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'net-ssh'
  gem.add_runtime_dependency 'serverspec'
  gem.add_runtime_dependency 'specinfra', '>= 1.18.4'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'aws-sdk'
  gem.add_development_dependency 'winrm'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
end