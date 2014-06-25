require 'nodespec/backend_proxy/ssh'

module NodeSpec
  module BackendProxy
    describe Ssh do
      let(:ssh_session) { double('ssh session') }
      let(:subject) {Ssh.new(ssh_session)}

      shared_examples 'an ssh session command run' do |user, original_command, actual_command|
        before do
          ssh_session.stub(options: {user: user})
          allow(subject).to receive(:execute_within_timeout).with(actual_command).and_yield
        end
        
        it 'returns true if the command succeeds' do
          allow(ssh_session).to receive(:exec!).with(actual_command).and_yield(nil, 'a stream', 'test data')
          
          expect(subject.execute(original_command)).to be_truthy
        end

        it 'returns false if the command fails' do
          allow(ssh_session).to receive(:exec!).with(actual_command).and_yield(nil, :stderr, 'test data')
          
          expect(subject.execute(original_command)).to be_falsy
        end
      end
      
      it_behaves_like 'an ssh session command run', 'root', 'test command', 'test command'
      it_behaves_like 'an ssh session command run', 'some_user', 'test command', 'sudo test command'
    end
  end
end