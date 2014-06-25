require 'spec_helper'
require 'nodespec/backend_proxy/exec'

module NodeSpec
  module BackendProxy
    describe Exec do
      shared_examples 'a command run' do |original_command, actual_command, sudo_option|
        let(:cmd_status) { double('status') }

        before do
          NodeSpec::RunOptions.run_local_with_sudo = sudo_option
          allow(Open3).to receive(:capture2e).with(actual_command).and_return(['test output', cmd_status])
          allow(subject).to receive(:execute_within_timeout).with(actual_command).and_yield
        end

        
        it 'returns true if the command succeeds' do
          cmd_status.stub(success?: true)
          
          expect(subject.execute(original_command)).to be_truthy
        end

        it 'returns false if the command fails' do
          cmd_status.stub(success?: false)
          
          expect(subject.execute(original_command)).to be_falsy
        end
      end
      
      it_behaves_like 'a command run', 'test command', 'test command', false
      it_behaves_like 'a command run', 'test command', 'sudo test command', true
    end
  end
end