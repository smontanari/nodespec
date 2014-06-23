require 'spec_helper'
require 'nodespec/local_command_runner'

module NodeSpec
  describe LocalCommandRunner do
    let(:subject) {Object.new.extend LocalCommandRunner}
    let(:cmd_status) { double('status') }

    before do
      allow(Open3).to receive(:capture2e).with('test command').and_return(['test output', cmd_status])
      allow(subject).to receive(:execute_within_timeout).with('test command').and_yield
    end

    it 'returns true if the command succeeds' do
      cmd_status.stub(success?: true)
      
      expect(subject.run_command('test command')).to be_truthy
    end

    it 'returns false if the command fails' do
      cmd_status.stub(success?: false)
      
      expect(subject.run_command('test command')).to be_falsy
    end
  end
end