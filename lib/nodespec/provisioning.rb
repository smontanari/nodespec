Dir[File.join(File.dirname(__FILE__), 'provisioning/*.rb')].each {|f| require f}

module NodeSpec
  module Provisioning
    self.constants.each do |provisioner_name|
      provisioner_class = self.const_get(provisioner_name)
      define_method("provision_node_with_#{provisioner_name.downcase}".to_sym) do |&block|
        @provisioners ||= {}
        @provisioners[provisioner_name.downcase] = provisioner_class.new(NodeSpec.current_node) unless @provisioners.key?(provisioner_name.downcase)
        @provisioners[provisioner_name.downcase].instance_eval(&block)
      end
    end
  end
end