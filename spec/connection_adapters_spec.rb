require 'nodespec/connection_adapters'
%w[vagrant ssh aws_ec2 winrm].each {|f| require "nodespec/connection_adapters/#{f}"}

module NodeSpec
  describe ConnectionAdapters do
    {
      'vagrant' => ConnectionAdapters::Vagrant,
      'ssh'     => ConnectionAdapters::Ssh,
      'aws_ec2' => ConnectionAdapters::AwsEc2,
      'winrm'   => ConnectionAdapters::Winrm
    }.each do |adapter_name, adapter_class|
      it "returns an instance of #{adapter_class}" do
        expect(adapter_class).to receive(:new).with('test_node', 'adapter_options' => 'test_options').and_return('adapter')
        adapter = ConnectionAdapters.get('test_node', adapter_name, 'adapter_options' => 'test_options')

        expect(adapter).to eq('adapter')
      end
    end
  end
end