require 'nodespec/backend_proxy/unixshell_utility'

module NodeSpec
  module BackendProxy
    describe UnixshellUtility do
      let(:subject) {Object.new.extend UnixshellUtility}

      it 'returns the command as run by sudo' do
        expect(subject.run_as_sudo('command')).to eq 'sudo command'
      end

      it 'returns the command to create a directory' do
        expect(subject.cmd_create_directory('/path to/dir')).to eq('sh -c "mkdir -p /path\ to/dir"')
      end

      it 'writes the given content to a file' do
        content = <<-eos
some 'text'
some "other" text
eos
        expect(subject.cmd_create_file('/path to/file', content)).to eq %Q[sh -c "cat > /path\\ to/file << EOF\nsome 'text'\nsome \\"other\\" text\nEOF"]
      end
    end
  end
end