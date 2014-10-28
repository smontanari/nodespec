require 'rspec'

require 'serverspec'
require 'nodespec/node_configurations'
require 'nodespec/run_options'
require 'nodespec/provisioning'

module NodeSpec
  class << self
    attr_reader :current_node
    def set_current_node(name, options)
      @current_node = NodeConfigurations.instance.get(name, options)
      yield(@current_node) if block_given?
    end
  end
end

RSpec.configure do |config|
  config.before :all do |eg|
    if eg.class.metadata.key?(:nodespec)
      NodeSpec.set_current_node(eg.class.description, eg.class.metadata[:nodespec]) do |node|
        Specinfra.configuration.backend = node.backend
        property[:os] = {}
        config.os = Specinfra::Helper::DetectOs.const_get(node.os).detect if node.os && node.os != 'Windows'
        node.communicator.bind_to(config)
      end
    end
  end

  config.include(NodeSpec::Provisioning)
end
