Dir[File.join(File.dirname(__FILE__), 'connection_adapters/*.rb')].each {|f| require f}

module NodeSpec
  module ConnectionAdapters
    def self.get(node_description, adapter_name, adapter_options)
      clazz = adapter_class(adapter_name)
      clazz.new(node_description, adapter_options)
    end

    private

    def self.adapter_class(name)
      adapter_classname = name.split('_').map(&:capitalize).join('')
      Adapters.const_get(adapter_classname)
    end
  end
end