require 'rspec'
module NodeSpec
  module SharedExamplesSupport
    def it_is_node_with_roles *instance_roles
      instance_roles.each {|role| it_behaves_like role}
    end
  end
end

RSpec.configure do |config|
  config.alias_it_behaves_like_to :it_is_node_configured_with, 'is a node configured with:'
  config.extend NodeSpec::SharedExamplesSupport
end