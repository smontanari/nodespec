require 'spec_helper'
require 'nodespec/communication_adapters/winrm'

module NodeSpec
  module CommunicationAdapters
    describe Winrm do
      include_examples 'new_communicator', Winrm, 'winrm'
    end
  end
end
