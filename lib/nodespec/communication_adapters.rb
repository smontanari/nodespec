module NodeSpec
  module CommunicationAdapters
    def self.get(node_name, adapter_name, adapter_options)
      require_relative "communication_adapters/#{adapter_name}.rb"
      clazz = adapter_class(adapter_name)
      clazz.new(node_name, adapter_options)
    end

    private

    def self.adapter_class(name)
      adapter_classname = name.split('_').map(&:capitalize).join('')
      self.const_get(adapter_classname)
    end
  end
end