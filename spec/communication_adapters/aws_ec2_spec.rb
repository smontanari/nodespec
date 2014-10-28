require 'aws-sdk'
require 'spec_helper'
require 'nodespec/communication_adapters/aws_ec2'

module NodeSpec
  module CommunicationAdapters
    describe AwsEc2 do
      let(:ec2_instance) {double('ec2 instance')}

      before do
        instance_collection = double
        allow(AWS).to receive_message_chain(:ec2, :instances).and_return(instance_collection)
        allow(instance_collection).to receive(:[]).with('test-instance').and_return(ec2_instance)
      end

      describe 'connecting to a running instance' do
        before do
          allow(ec2_instance).to receive(:exists?).ordered.and_return(true)
          allow(ec2_instance).to receive(:status).ordered.and_return(:running)
          allow(ec2_instance).to receive(:public_dns_name).ordered.and_return('test.host.name')
        end

        %w[ssh winrm].each do |connection|
          describe "#{connection} communicator" do
            include_context "new_#{connection}_communicator", 'test.host.name', 'foo' => 'bar'

            it 'returns communicator with the instance name from the node name' do
              expect(AwsEc2.communicator_for('test-instance', connection => {'foo' => 'bar'})).to eq("#{connection} communicator")
            end

            it 'returns communicator with the instance name from the options' do
              expect(AwsEc2.communicator_for('test_node', 'instance' => 'test-instance', connection => {'foo' => 'bar'})).to eq("#{connection} communicator")
            end
          end
        end

        describe 'openssh default connection' do
          include_context "new_ssh_communicator", 'test.host.name', {}

          it 'returns an ssh communicator' do
            expect(AwsEc2.communicator_for('test-instance')).to eq("ssh communicator")
          end
        end
      end

      describe 'connecting to an unreachable instance' do
        context 'not existing instance' do
          before do
            allow(ec2_instance).to receive(:exists?).ordered.and_return(false)
          end

          it 'raises an error' do
            expect {AwsEc2.communicator_for('test-instance', 'foo' => 'bar')}.to raise_error
          end
        end

        context 'not running instance' do
          before do
            allow(ec2_instance).to receive(:exists?).ordered.and_return(true)
            allow(ec2_instance).to receive(:status).ordered.and_return(:whatever_else)
          end

          it 'raises an error' do
            expect {AwsEc2.communicator_for('test-instance', 'foo' => 'bar')}.to raise_error
          end
        end
      end
    end
  end
end