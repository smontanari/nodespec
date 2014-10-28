require 'nodespec/communication_adapters'
%w[vagrant ssh aws_ec2 winrm].each {|f| require "nodespec/communication_adapters/#{f}"}

module NodeSpec
  describe CommunicationAdapters do
    {
      'vagrant' => CommunicationAdapters::Vagrant,
      'ssh'     => CommunicationAdapters::Ssh,
      'aws_ec2' => CommunicationAdapters::AwsEc2,
      'winrm'   => CommunicationAdapters::Winrm
    }.each do |adapter_name, adapter_class|
      it "retrieves a communicator from #{adapter_class}" do
        expect(adapter_class).to receive(:communicator_for).with('test_node', 'adapter_options' => 'test_options').and_return('communicator')

        communicator = CommunicationAdapters.get_communicator('test_node', adapter_name, 'adapter_options' => 'test_options')

        expect(communicator).to eq('communicator')
      end
    end

    it 'defaults to a NativeCommunicator' do
      expect(CommunicationAdapters::NativeCommunicator).to receive(:new).and_return('communicator')

      communicator = CommunicationAdapters.get_communicator('test_node')

      expect(communicator).to eq('communicator')
    end
  end
end