Dir[File.join(File.dirname(__FILE__), 'provisioning/*.rb')].each {|f| require f}

module NodeSpec
  module Provisioning
    self.constants.each do |provisioner_name|
      provisioner_class = self.const_get(provisioner_name)
      define_method("provision_node_with_#{provisioner_name.downcase}".to_sym) do |&block|
        @provisioner ||= provisioner_class.new(NodeSpec.current_node)
        @provisioner.instance_eval(&block)
      end
    end
  end
end