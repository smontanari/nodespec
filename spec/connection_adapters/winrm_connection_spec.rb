require 'winrm'
require 'nodespec/connection_adapters/winrm_connection'

module NodeSpec
  module ConnectionAdapters
    describe WinrmConnection do
      let(:rspec_configuration) {double('rspec configuration')}
      let(:winrm_session) {double('winrm session')}

      before do
        allow(WinRM::WinRMWebService).to receive(:new).with('http://test.host.name:1234/wsman', :test_transport, option1: 'test_opt1', option2: 'test_opt2').and_return('new session')
        [:winrm, :winrm=].each {|method| allow(rspec_configuration).to receive(method)}
      end

      shared_context 'existing session' do |endpoint|
        before do
          allow(rspec_configuration).to receive(:winrm).and_return(winrm_session)
          allow(winrm_session).to receive(:endpoint).and_return(endpoint)
        end
      end

      shared_examples 'creating new session' do
        before do
          expect(rspec_configuration).to receive(:winrm=).with('new session')
        end

        it 'creates and holds a new session' do
          subject.bind_to(rspec_configuration)

          expect(subject.session).to eq('new session')
        end
      end

      describe 'binding to configuration' do
        let(:subject) { WinrmConnection.new(
          'http://test.host.name:1234/wsman', :test_transport, option1: 'test_opt1', option2: 'test_opt2')
        }

        describe '#bind_to' do
          context 'no existing session' do
            before do
              allow(rspec_configuration).to receive(:winrm).and_return(nil)
            end

            include_examples 'creating new session'
          end

          context 'existing session with different endpoint' do
            include_context 'existing session', 'http://test.another.host.name:1234/wsman'
            include_examples 'creating new session'
          end

          context 'existing session with same connection' do
            include_context 'existing session', 'http://test.host.name:1234/wsman'

            context 'open session' do
              it 'does not change the current rspec configuration' do
                expect(WinRM::WinRMWebService).not_to receive(:new)
                expect(rspec_configuration).not_to receive(:winrm=)
          
                subject.bind_to(rspec_configuration)

                expect(subject.session).to eq(winrm_session)
              end
            end
          end
        end
      end
    end
  end
end