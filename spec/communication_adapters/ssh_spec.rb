require 'spec_helper'
require 'nodespec/communication_adapters/ssh'

module NodeSpec
  module CommunicationAdapters
    describe Ssh do
      include_examples 'new_communicator', Ssh, 'ssh'
    end
  end
end
