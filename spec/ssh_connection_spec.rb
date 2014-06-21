require 'nodespec/ssh_connection'

module NodeSpec
  describe SshConnection do
    let(:subject) {SshConnection.new('test host', 'test user', 'ssh options')}
    let(:rspec_configuration) {double('rspec configuration')}
    let(:ssh_session) {double('ssh session')}
    
    before do
      allow(Net::SSH).to receive(:start).with('test host', 'test user', 'ssh options').and_return('new session')
      [:ssh, :ssh=, :host, :host=].each {|method| allow(rspec_configuration).to receive(method)}
    end

    describe '#bind' do
      shared_examples 'new session' do
        before {rspec_configuration.stub(:ssh).and_return(nil, nil, 'new session')}

        it 'starts a new ssh session in the rspec configuration ' do
          expect(rspec_configuration).to receive(:ssh=).with('new session')

          subject.bind(rspec_configuration)
        end
        
        it 'sets the new hostname in the rspec configuration ' do
          expect(rspec_configuration).to receive(:host=).with('test host')

          subject.bind(rspec_configuration)
        end

        it 'holds the session' do
          subject.bind(rspec_configuration)

          expect(subject.session).to eq('new session')
        end
      end

      context 'different or no hostname' do
        [nil, 'another host'].each do |current_hostname|
          before { rspec_configuration.stub(host: current_hostname) }

          it 'closes an existing ssh session' do
            rspec_configuration.stub(ssh: ssh_session)
            expect(ssh_session).to receive(:close)
            ssh_session.stub(closed?: true)

            subject.bind(rspec_configuration)
          end

          include_examples 'new session'
        end
      end

      context 'same hostname' do
        before { rspec_configuration.stub(host: 'test host') }

        context 'no session' do
          include_examples 'new session'
        end

        context 'existing session' do
          before { rspec_configuration.stub(ssh: ssh_session) }
        
          context 'open session' do
            before { ssh_session.stub(closed?: false) }

            it 'does not change the current rspec configuration' do
              expect(Net::SSH).not_to receive(:start)
              expect(rspec_configuration).not_to receive(:ssh=)
              expect(rspec_configuration).not_to receive(:host=)
        
              subject.bind(rspec_configuration)

              expect(subject.session).to eq(ssh_session)
            end
          end

          context 'closed session' do
            before { ssh_session.stub(closed?: true) }
            include_examples 'new session'
          end
        end
      end
    end
  end
end