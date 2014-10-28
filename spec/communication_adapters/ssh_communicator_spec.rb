require 'nodespec/communication_adapters/ssh_communicator'

module NodeSpec
  module CommunicationAdapters
    describe SshCommunicator do
      let(:rspec_configuration) {double('rspec configuration')}
      let(:ssh_session) {double('ssh session')}

      before do
        allow(Net::SSH).to receive(:start).with('test.host.name', 'testuser', port: 1234, password: 'testpassword', keys: 'testkeys').and_return(ssh_session)
      end

      shared_context 'existing session' do |hostname, port|
        before do
          allow(rspec_configuration).to receive(:ssh).and_return(ssh_session)
          allow(ssh_session).to receive(:host).and_return(hostname)
          allow(ssh_session).to receive(:options).and_return({port: port})
        end
      end

      shared_examples 'creating new session' do |port|
        before do
          allow(ssh_session).to receive(:options).and_return({port: port})
          expect(rspec_configuration).to receive(:ssh=).with(ssh_session)
          expect(rspec_configuration).to receive(:ssh_options=).with({port: port})
          expect(rspec_configuration).to receive(:host=).with('test.host.name')
        end

        it 'creates and holds a new session' do
          subject.bind_to(rspec_configuration)

          expect(subject.session).to eq(ssh_session)
        end
      end

      shared_examples 'binding to configuration' do
        before do
          allow(rspec_configuration).to receive(:winrm)
        end

        context 'existing winrm session' do
          before do
            allow(rspec_configuration).to receive(:winrm).and_return('winrm')
            allow(rspec_configuration).to receive(:ssh).and_return(nil)
            expect(rspec_configuration).to receive(:winrm=).with(nil)
          end

          include_examples 'creating new session', 1234
        end

        context 'no existing ssh session' do
          before do
            allow(rspec_configuration).to receive(:ssh).and_return(nil)
          end

          include_examples 'creating new session', 1234
        end

        {'another host' => 1234, 'test.host.name' => 5678}.each do |hostname, port|
          context 'existing session with different connection' do
            include_context 'existing session', hostname, port
            before do
              expect(ssh_session).to receive(:close)
              allow(ssh_session).to receive(:closed?).and_return(true)
            end
            include_examples 'creating new session', 5678
          end
        end

        context 'existing ssh session with same connection' do
          include_context 'existing session', 'test.host.name', 1234
          context 'open session' do
            before { allow(ssh_session).to receive(:closed?).and_return(false) }

            it 'does not change the current rspec configuration' do
              expect(Net::SSH).not_to receive(:start)
              expect(rspec_configuration).not_to receive(:ssh=)
              expect(rspec_configuration).not_to receive(:ssh_options=)
              expect(rspec_configuration).not_to receive(:host=)

              subject.bind_to(rspec_configuration)

              expect(subject.session).to eq(ssh_session)
            end
          end

          context 'closed session' do
            before { allow(ssh_session).to receive(:closed?).and_return(true) }
            include_examples 'creating new session', 1234
          end
        end
      end

      context 'with given credentials' do
        let(:subject) {SshCommunicator.new('test.host.name', nil, 'port' => 1234, 'user' => 'testuser', 'password' => 'testpassword', 'keys' => 'testkeys')}
        before do
          allow(Net::SSH).to receive(:configuration_for).and_return({})
        end
        include_examples 'binding to configuration'
      end

      context 'credentials from OpenSSH config files' do
        let(:subject) {SshCommunicator.new('test.host.name', nil, 'port' => 1234, 'user' => 'testuser')}
        before do
          allow(Net::SSH).to receive(:configuration_for).with('test.host.name').and_return(password: 'testpassword', keys: 'testkeys')
        end

        include_examples 'binding to configuration'
      end

      it 'provides a remote backend' do
        expect(SshCommunicator.new('test.host.name')).to be_a(RemoteBackend)
      end

      describe '#initialize' do
        [nil, 'Test OS'].each do |os|
          it 'holds the os information' do
            expect(SshCommunicator.new('test.host.name', os, {}).os).to eq os
          end
        end
      end
    end
  end
end