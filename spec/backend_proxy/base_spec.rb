require 'nodespec/backend_proxy/base'

module NodeSpec
  module BackendProxy
    describe Base do
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

      it 'behaves like a command execution' do
        expect(subject).to respond_to(:execute_within_timeout)
      end
    end
  end
end