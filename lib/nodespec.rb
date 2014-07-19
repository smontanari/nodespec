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

RSpec.configure do |c|
  c.before :all do |eg|
    NodeSpec.set_current_node(eg.class.description, eg.class.metadata[:node_config]) do |node|
      c.os = node.os
      node.connection.bind_to(c) 
    end 
  end

  c.before :each do
    subject_type = subject.class.name.rpartition('::').first
    if subject_type == Serverspec::Type.name
      subject.extend SpecInfra::Helper.const_get(NodeSpec.current_node.backend)
      subject.extend SpecInfra::Helper.const_get(NodeSpec.current_node.os || 'DetectOS')
    end
  end

  c.include(NodeSpec::Provisioning)
end
