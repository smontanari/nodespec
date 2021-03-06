require 'nodespec/command_execution'

module NodeSpec
  describe CommandExecution do
    subject {Object.new.extend CommandExecution}

    it 'does not raise an error if the command succeeds' do
      subject.execute_within_timeout('test command') { true }
    end

    it 'raises an error if the command fails' do
      expect {
        subject.execute_within_timeout('test command') { false }
      }.to raise_error CommandExecution::CommandExecutionError
    end

    context 'custom timeout' do
      it 'fails if running longer than the set timeout' do
        expect {
          subject.execute_within_timeout('test command', 1) { sleep(2) }
        }.to raise_error Timeout::Error
      end
    end

    context 'preset timeout' do
      before do
        NodeSpec::RunOptions.command_timeout = 1
      end
      it 'fails if running longer than the set timeout' do
        expect {
          subject.execute_within_timeout('test command') { sleep(2) }
        }.to raise_error Timeout::Error
      end
    end
  end
end