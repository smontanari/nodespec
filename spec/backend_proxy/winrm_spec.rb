require 'nodespec/backend_proxy/winrm'

module NodeSpec
  module BackendProxy
    describe Winrm do
      let(:winrm) { double('winrm session') }
      let(:subject) {Winrm.new(winrm)}
      before do
        allow(winrm).to receive(:set_timeout).with(NodeSpec::RunOptions.command_timeout)
      end

      it 'returns true upon successful execution' do
        result = {exitcode: 0, data: [{stdout: 'output line 1'}, {stdout: 'output line 2'}]}
        allow(winrm).to receive(:powershell).and_return(result)

        expect(subject.execute('command')).to be_truthy
      end

      it 'returns false if stderr not empty' do
        result = {exitcode: 0, data: [{stdout: 'output line 1', stderr: 'error line 1'}, {stdout: 'output line 2', stderr: 'error line 2'}]}
        allow(winrm).to receive(:powershell).and_return(result)

        expect(subject.execute('command')).to be_falsy
      end

      it 'returns false if exitcode not zero' do
        result = {exitcode: 1, data: [{stdout: 'output line 1'}, {stdout: 'output line 2'}]}
        allow(winrm).to receive(:powershell).and_return(result)

        expect(subject.execute('command')).to be_falsy
      end
    end
  end
end
