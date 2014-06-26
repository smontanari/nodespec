require 'nodespec/backend_proxy/base'

module NodeSpec
  module BackendProxy
    describe Base do
      it 'does not raise an error if the command succeeds' do
        subject.execute_within_timeout('test command') { true }
      end

      it 'raises an error if the command fails' do
        expect {
          subject.execute_within_timeout('test command') { false }
        }.to raise_error CommandExecutionError
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

      describe '#create_file' do
        it 'executes the generated command' do
          allow(subject).to receive(:cmd_create_file).with('test/path', 'test content').and_return('command')
          expect(subject).to receive(:execute).with('command')

          subject.create_file('test/path', 'test content')
        end
      end

      describe '#create_directory' do
        it 'executes the generated command' do
          allow(subject).to receive(:cmd_create_directory).with('test/path').and_return('command')
          expect(subject).to receive(:execute).with('command')

          subject.create_directory('test/path')
        end
      end
    end
  end
end