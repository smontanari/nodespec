require 'nodespec/connection_adapters/ssh_connection'

module NodeSpec
  module ConnectionAdapters
    describe SshConnection do
      let(:rspec_configuration) {double('rspec configuration')}
      let(:ssh_session) {double('ssh session')}

      before do
        allow(Net::SSH).to receive(:start).with('test.host.name', 'testuser', port: 1234, password: 'testpassword', keys: 'testkeys').and_return('new session')
        [:ssh, :ssh=, :host=].each {|method| allow(rspec_configuration).to receive(method)}
      end

      shared_context 'existing session' do |hostname, port|
        before do
          allow(rspec_configuration).to receive(:ssh).and_return(ssh_session)
          allow(ssh_session).to receive(:host).and_return(hostname)
          allow(ssh_session).to receive(:options).and_return({port: port})
        end
      end

      shared_examples 'creating new session' do
        before do
          expect(rspec_configuration).to receive(:ssh=).with('new session')
          expect(rspec_configuration).to receive(:host=).with('test.host.name')
        end

        it 'creates and holds a new session' do
          subject.bind_to(rspec_configuration)

          expect(subject.session).to eq('new session')
        end
      end

      shared_examples 'binding to configuration' do
        describe '#bind_to' do
          context 'no existing session' do
            before do
              allow(rspec_configuration).to receive(:ssh).and_return(nil)
            end

            include_examples 'creating new session'
          end

          {'another host' => 1234, 'test.host.name' => 5678}.each do |hostname, port|
            context 'existing session with different connection' do
              include_context 'existing session', hostname, port
              before do
                expect(ssh_session).to receive(:close)
                allow(ssh_session).to receive(:closed?).and_return(true)
              end
              include_examples 'creating new session'
            end
          end

          context 'existing session with same connection' do
            include_context 'existing session', 'test.host.name', 1234          
            context 'open session' do
              before { allow(ssh_session).to receive(:closed?).and_return(false) }

              it 'does not change the current rspec configuration' do
                expect(Net::SSH).not_to receive(:start)
                expect(rspec_configuration).not_to receive(:ssh=)
                expect(rspec_configuration).not_to receive(:host=)
          
                subject.bind_to(rspec_configuration)

                expect(subject.session).to eq(ssh_session)
              end
            end

            context 'closed session' do
              before { allow(ssh_session).to receive(:closed?).and_return(true) }
              include_examples 'creating new session'
            end
          end
        end
      end

      context 'with given credentials' do
        let(:subject) {SshConnection.new('test.host.name', 'port' => 1234, 'user' => 'testuser', 'password' => 'testpassword', 'keys' => 'testkeys')}
        before do
          allow(Net::SSH).to receive(:configuration_for).and_return({})
        end
        include_examples 'binding to configuration'
      end

      context 'credentials from OpenSSH config files' do
        let(:subject) {SshConnection.new('test.host.name', 'port' => 1234, 'user' => 'testuser')}
        before do
          allow(Net::SSH).to receive(:configuration_for).with('test.host.name').and_return(password: 'testpassword', keys: 'testkeys')
        end

        include_examples 'binding to configuration'
      end

      it 'is a Remote connection' do
        expect(SshConnection.new('test.host.name', {})).to be_a(Remote)
      end
    end
  end
end