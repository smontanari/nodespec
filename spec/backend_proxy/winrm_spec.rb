require 'nodespec/backend_proxy/winrm'

module NodeSpec
  module BackendProxy
    describe WinRM do
      let(:winrm) { double('winrm session') }
      let(:subject) {WinRM.new(winrm)}

      it 'returns true upon successful execution' do
        result = {data: [{stdout: 'output line 1'}, {stdout: 'output line 2'}]}
        allow(winrm).to receive(:powershell).and_return(result)

        expect(subject.execute('command')).to be_truthy
      end

      it 'returns false upon failed execution' do
        result = {data: [{stdout: 'output line 1', stderr: 'error line 1'}, {stdout: 'output line 2', stderr: 'error line 2'}]}
        allow(winrm).to receive(:powershell).and_return(result)

        expect(subject.execute('command')).to be_falsy
      end
    end
  end
end
