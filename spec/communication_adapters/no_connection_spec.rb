require 'nodespec/communication_adapters/no_connection'

module NodeSpec
  module CommunicationAdapters
    describe NoConnection do
      it 'is a Local connection' do
        expect(NoConnection.new).to be_a(Local)
      end

      describe '#bind_to' do
        let(:rspec_configuration) {double('rspec configuration')}

        context('ssh session') do
          let(:ssh_session) {double('ssh session')}

          before do
            allow(rspec_configuration).to receive(:ssh).and_return(ssh_session)
            allow(rspec_configuration).to receive(:winrm)
            [:close, :host].each {|m| allow(ssh_session).to receive(m)}
            allow(ssh_session).to receive(:options).and_return({port: 'port'})
            expect(rspec_configuration).to receive(:ssh=).with(nil)
          end

          it 'closes and removes an existing ssh session' do
            subject.bind_to(rspec_configuration)
          end
        end

        context('winrm session') do
          let(:winrm_session) {double('winrm session')}

          before do
            allow(rspec_configuration).to receive(:ssh)
            allow(rspec_configuration).to receive(:winrm).and_return(winrm_session)
            expect(rspec_configuration).to receive(:winrm=).with(nil)
          end

          it 'removes an existing winrm session' do
            subject.bind_to(rspec_configuration)
          end
        end
      end
    end
  end
end