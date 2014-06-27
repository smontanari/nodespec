require 'nodespec/ssh_connection'

module NodeSpec
  describe SshConnection do
    let(:rspec_configuration) {double('rspec configuration')}
    let(:ssh_session) {double('ssh session')}

    before do
      allow(Net::SSH).to receive(:configuration_for).and_return({})
      allow(Net::SSH).to receive(:start).with('test.host.name', 'testuser', port: 1234, password: 'testpassword', keys: 'testkeys').and_return('new session')
      [:ssh, :ssh=, :host, :host=].each {|method| allow(rspec_configuration).to receive(method)}
    end

    shared_examples 'creating new session' do
      before {allow(rspec_configuration).to receive(:ssh).and_return(nil, nil, 'new session')}

      it 'starts a new ssh session in the rspec configuration ' do
        expect(rspec_configuration).to receive(:ssh=).with('new session')

        subject.bind_to(rspec_configuration)
      end
      
      it 'sets the new hostname in the rspec configuration ' do
        expect(rspec_configuration).to receive(:host=).with('test.host.name')

        subject.bind_to(rspec_configuration)
      end

      it 'holds the session' do
        subject.bind_to(rspec_configuration)

        expect(subject.session).to eq('new session')
      end
    end

    shared_examples 'binding to configuration' do
      describe '#bind_to' do
        context 'different or no hostname' do
          [nil, 'another host'].each do |current_hostname|
            before { allow(rspec_configuration).to receive(:host).and_return(current_hostname) }

            it 'closes an existing ssh session' do
              allow(rspec_configuration).to receive(:ssh).and_return(ssh_session)
              expect(ssh_session).to receive(:close)
              allow(ssh_session).to receive(:closed?).and_return(true)

              subject.bind_to(rspec_configuration)
            end

            include_examples 'creating new session'
          end
        end

        context 'same hostname' do
          before { allow(rspec_configuration).to receive(:host).and_return('test.host.name') }

          context 'no session' do
            include_examples 'creating new session'
          end

          context 'existing session' do
            before { allow(rspec_configuration).to receive(:ssh).and_return(ssh_session) }
          
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
    end

    context 'with given credentials' do
      let(:subject) {SshConnection.new('host' => 'test.host.name', 'port' => 1234, 'user' => 'testuser', 'password' => 'testpassword', 'keys' => 'testkeys')}
      before do
        allow(Net::SSH).to receive(:configuration_for).and_return({})
      end
      include_examples 'binding to configuration'
    end

    context 'credentials from OpenSSH config files' do
      let(:subject) {SshConnection.new('host' => 'test.host.name', 'port' => 1234, 'user' => 'testuser')}
      before do
        allow(Net::SSH).to receive(:configuration_for).with('test.host.name').and_return(password: 'testpassword', keys: 'testkeys')
      end

      include_examples 'binding to configuration'
    end
  end
end