require 'nodespec/communication_adapters/native_communicator'

module NodeSpec
  module CommunicationAdapters
    def self.get_communicator(node_name, adapter_name = nil, adapter_options = {})
      if adapter_name
        require_relative "communication_adapters/#{adapter_name}.rb"
        clazz = adapter_class(adapter_name)
        clazz.communicator_for(node_name, adapter_options)
      else
        NativeCommunicator.new
      end
    end

    private

    def self.adapter_class(name)
      adapter_classname = name.split('_').map(&:capitalize).join('')
      self.const_get(adapter_classname)
    end
  end
end