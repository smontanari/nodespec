require 'specinfra/backend'
%w[exec cmd ssh winrm].each {|f| require_relative "backend_proxy/#{f}"}

module NodeSpec
  module BackendProxy
    PROXIES = {
      exec:  'Exec',
      ssh:   'Ssh',
      cmd:   'Cmd',
      winrm: 'Winrm'
    }
    class SpecinfraCompatibilityError < StandardError; end

    PROXIES.values.each do |name|
      raise SpecinfraCompatibilityError.new("Specinfra::Backend::#{name} is not defined!") unless Specinfra::Backend.const_defined?(name)
    end

    def self.create(backend, *args)
      class_name = PROXIES.fetch(backend, PROXIES[:exec])
      self.const_get(class_name).send(:new, *args)
    end
  end
end