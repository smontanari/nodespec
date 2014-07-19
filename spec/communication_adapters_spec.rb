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
      it "returns an instance of #{adapter_class}" do
        expect(adapter_class).to receive(:new).with('test_node', 'adapter_options' => 'test_options').and_return('adapter')
        adapter = CommunicationAdapters.get('test_node', adapter_name, 'adapter_options' => 'test_options')

        expect(adapter).to eq('adapter')
      end
    end
  end
end