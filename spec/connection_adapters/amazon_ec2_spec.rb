require 'aws-sdk'
require 'spec_helper'
require 'nodespec/connection_adapters/amazon_ec2'

module NodeSpec
  module ConnectionAdapters
    describe AmazonEc2 do
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
          allow(ec2_instance).to receive(:public_dns_name).ordered.and_return('test hostname')
        end
        context 'instance name from the node name' do
          let(:subject) {AmazonEc2.new('test-instance', 'foo' => 'bar')}
          include_examples 'valid_ssh_connection', 'host' => 'test hostname', 'foo' => 'bar'
        end
        context 'instance name from the options' do
          let(:subject) {AmazonEc2.new('test_node', 'instance' => 'test-instance', 'foo' => 'bar')}
          include_examples 'valid_ssh_connection', 'host' => 'test hostname', 'foo' => 'bar'
        end
      end

      describe 'connecting to an unreachable instance' do
        context 'not existing instance' do
          before do
            allow(ec2_instance).to receive(:exists?).ordered.and_return(false)
          end

          it 'raises an error' do
            expect {AmazonEc2.new('test-instance', 'foo' => 'bar')}.to raise_error
          end
        end

        context 'not running instance' do
          before do
            allow(ec2_instance).to receive(:exists?).ordered.and_return(true)
            allow(ec2_instance).to receive(:status).ordered.and_return(:whatever_else)
          end

          it 'raises an error' do
            expect {AmazonEc2.new('test-instance', 'foo' => 'bar')}.to raise_error
          end
        end
      end
    end
  end
end