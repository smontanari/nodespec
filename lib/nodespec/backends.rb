require 'specinfra/helper'

module NodeSpec
  module Backends
    class SpecInfraCompatibilityError < StandardError; end

    %w[Exec Ssh Cmd WinRM].each do |name|
      raise SpecInfraCompatibilityError.new("module SpecInfra::Helper::#{name} is not defined!") unless SpecInfra::Helper.const_defined?(name)
      const_set(name, name)
    end
  end
end