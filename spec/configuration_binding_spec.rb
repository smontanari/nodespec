require 'nodespec/configuration_binding'

module NodeSpec
  describe ConfigurationBinding do
    subject {ConfigurationBinding.new(configuration)}

    let(:configuration) { double('configuration') }
    let(:existing_session) {double('existing session')}
    let(:new_session) {double('new session')}

    describe '#bind_ssh_session_for' do
      shared_examples 'bind ssh session' do
        it 'binds the session' do
          allow(new_session).to receive(:host).and_return('test.host.name')
          allow(new_session).to receive(:options).and_return({port: 1234})
          expect(configuration).to receive(:ssh=).with(new_session)
          expect(configuration).to receive(:ssh_options=).with({port: 1234})
          expect(configuration).to receive(:host=).with('test.host.name')

          session = subject.bind_ssh_session_for('test.host.name', 1234) {new_session}
          expect(session).to be(new_session)
        end
      end

      context 'different or no session' do
        before do
          expect(configuration).to receive(:ssh=).with(nil)
          expect(configuration).to receive(:ssh_options=).with(nil)
          expect(configuration).to receive(:host=).with(nil)
        end

        context 'not existing session' do
          before do
            allow(configuration).to receive(:ssh).and_return(nil)
          end

          include_examples 'bind ssh session'
        end

        context 'different existing session' do
          before do
            allow(configuration).to receive(:ssh).and_return(existing_session)
            expect(existing_session).to receive(:close)
          end

          context 'different host' do
            before do
              allow(existing_session).to receive(:host).and_return('test.anotherhost.name')
              allow(existing_session).to receive(:options).and_return({port: 1234})
            end

            include_examples 'bind ssh session'
          end

          context 'different port' do
            before do
              allow(existing_session).to receive(:host).and_return('test.host.name')
              allow(existing_session).to receive(:options).and_return({port: 5678})
            end

            include_examples 'bind ssh session'
          end
        end
      end

      context 'same session' do
        before do
          allow(configuration).to receive(:ssh).and_return(existing_session)
          allow(existing_session).to receive(:host).and_return('test.host.name')
          allow(existing_session).to receive(:options).and_return({port: 1234})
          expect(existing_session).not_to receive(:close)
          expect(configuration).not_to receive(:ssh=)
          expect(configuration).not_to receive(:ssh_options=)
          expect(configuration).not_to receive(:host=)
        end

        it 'does not change the exisintg session' do
          session = subject.bind_ssh_session_for('test.host.name', 1234) {new_session}
          expect(session).to be(existing_session)
        end
      end
    end

    describe '#unbind_ssh_session' do
      before do
        allow(configuration).to receive(:ssh).and_return(existing_session)
        expect(existing_session).to receive(:host)
        expect(existing_session).to receive(:options).and_return({})
        expect(existing_session).to receive(:close)
        expect(configuration).to receive(:ssh=).with(nil)
        expect(configuration).to receive(:ssh_options=).with(nil)
        expect(configuration).to receive(:host=).with(nil)
      end

      it 'removes ssh session from the configuration' do
        subject.unbind_ssh_session
      end
    end

    describe '#bind_winrm_session_for' do
      shared_examples 'bind winrm session' do
        it 'binds the session' do
          allow(new_session).to receive(:endpoint).and_return('test.endpoint')
          expect(configuration).to receive(:winrm=).with(new_session)
          expect(configuration).to receive(:host=).with('test.host.name')

          session = subject.bind_winrm_session_for('test.host.name', 'test.endpoint') {new_session}
          expect(session).to be(new_session)
        end
      end

      context 'different or no session' do
        before do
          expect(configuration).to receive(:winrm=).with(nil)
          expect(configuration).to receive(:host=).with(nil)
        end

        context 'not existing session' do
          before do
            allow(configuration).to receive(:winrm).and_return(nil)
          end

          include_examples 'bind winrm session'
        end

        context 'different existing session' do
          before do
            allow(configuration).to receive(:winrm).and_return(existing_session)
          end

          context 'different host' do
            before do
              allow(existing_session).to receive(:endpoint).and_return('test.anotherendpoint')
            end

            include_examples 'bind winrm session'
          end
        end
      end

      context 'same session' do
        before do
          allow(configuration).to receive(:winrm).and_return(existing_session)
          allow(existing_session).to receive(:endpoint).and_return('test.endpoint')
          expect(configuration).not_to receive(:winrm=)
          expect(configuration).not_to receive(:host=)
        end

        it 'does not change the exisintg session' do
          session = subject.bind_winrm_session_for('test.host.name', 'test.endpoint') {new_session}
          expect(session).to be(existing_session)
        end
      end
    end

    describe '#unbind_winrm_session' do
      before do
        expect(configuration).to receive(:winrm=).with(nil)
        expect(configuration).to receive(:host=).with(nil)
      end

      it 'removes winrm session from the configuration' do
        subject.unbind_winrm_session
      end
    end
  end
end