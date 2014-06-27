require 'nodespec/node'

module NodeSpec
  describe Node do
    shared_examples 'node_attributes' do |attributes|
      it "has the expected attributes" do
        expect(subject.os).to eq(attributes[:os])
        expect(subject.backend).to eq(attributes[:backend])
        expected_remote_connection = attributes[:remote_connection] ? remote_connection : nil
        expect(subject.remote_connection).to eq(expected_remote_connection)
      end
    end

    shared_examples 'run commands' do |helper|
      it "runs a command through the command helper" do
        expect(backend_proxy[helper]).to receive(:execute).with('test command')
        
        subject.execute('test command')
      end
      it "creates a directory with a path relative to the node working directory" do
        expect(backend_proxy[helper]).to receive(:create_directory).ordered.with('.nodespec')
        expect(backend_proxy[helper]).to receive(:create_directory).ordered.with('.nodespec/test_dir')
        
        expect(subject.create_directory('test_dir')).to eq('.nodespec/test_dir')
      end
      it "writes to a file with a path relative to the node working directory" do
        expect(backend_proxy[helper]).to receive(:create_directory).ordered.with('.nodespec')
        expect(backend_proxy[helper]).to receive(:create_file).ordered.with('.nodespec/test/file', 'test content')
        
        expect(subject.create_file('test/file', 'test content')).to eq('.nodespec/test/file')
      end
      it "creates a directory with an absolute path" do
        expect(backend_proxy[helper]).to receive(:create_directory).with('/test/dir')
        
        expect(subject.create_directory('/test/dir')).to eq('/test/dir')
      end
      it "writes to a file with an absolute path" do
        expect(backend_proxy[helper]).to receive(:create_file).with('/test/file', 'test content')
        
        expect(subject.create_file('/test/file', 'test content')).to eq('/test/file')
      end
    end

    let(:rspec_subject) {double('rspec subject')}
    let(:backend_proxy) {
      {
        exec_helper:  double('exec_helper'),
        cmd_helper:   double('cmd_helper'),
        ssh_helper:   double('ssh_helper'),
        winrm_helper: double('winrm_helper')
      }
    }

    before do
      allow(BackendProxy::Exec).to receive(:new).and_return(backend_proxy[:exec_helper])
      allow(BackendProxy::Cmd).to receive(:new).and_return(backend_proxy[:cmd_helper])
      allow(BackendProxy::Ssh).to receive(:new).with('remote session').and_return(backend_proxy[:ssh_helper])
      allow(BackendProxy::WinRM).to receive(:new).with('remote session').and_return(backend_proxy[:winrm_helper])
    end

    it 'does not change the original options' do
      Node.new('test_node', {'os' => 'test', 'foo' => 'bar'}.freeze)
    end

    describe 'node name' do
      it 'replaces spaces with hyphen' do
        subject = Node.new('test node description')
        expect(subject.name).to eq('test-node-description')
      end
      it 'trims spaces at the end' do
        subject = Node.new("test.node.description  ")
        expect(subject.name).to eq('test.node.description')
      end
      it 'cannot contain punctuation characters' do
        "!@#$%^&*()+={}[]\\|:;\"'<>?,/".each_char do |invalid_char|
          expect {Node.new("test #{invalid_char} name")}.to raise_error
        end
      end
      it 'cannot start with space, underscore or hyphen characters' do
        " _-".each_char do |invalid_char|
          expect {Node.new("#{invalid_char} name")}.to raise_error
        end
      end
    end

    context 'no options' do
      let(:subject) {Node.new('test_node')}
      
      include_examples 'node_attributes', {os: nil, backend: 'Exec', remote_connection: nil}
      include_examples 'run commands', :exec_helper
    end

    context 'options with unix-like os' do
      let(:subject) {Node.new('test_node', 'os' => 'Solaris')}
      
      include_examples 'node_attributes', {os: 'Solaris', backend: 'Exec', remote_connection: nil}
      include_examples 'run commands', :exec_helper
    end

    context 'options with windows os' do
      let(:subject) {Node.new('test_node', 'os' => 'Windows')}

      include_examples 'node_attributes', {os: 'Windows', backend: 'Cmd', remote_connection: nil}
      include_examples 'run commands', :cmd_helper
    end

    context 'options with adapter' do
      let(:adapter) {double('adapter')}
      let(:remote_connection) {double('remote connection')}
      before do
        allow(ConnectionAdapters).to receive(:get).with('test_node', 'test_adapter', 'foo' => 'bar').and_return(adapter)
        allow(adapter).to receive(:connection).and_return(remote_connection)
        allow(remote_connection).to receive(:session).and_return('remote session')
      end

      context 'no os given' do
        let(:subject) {Node.new('test_node', 'adapter' => 'test_adapter', 'foo' => 'bar')}

        include_examples 'node_attributes', {os: nil, backend: 'Ssh', remote_connection: true}
        include_examples 'run commands', :ssh_helper
      end

      context 'unix-like os given' do
        let(:subject) {Node.new('test_node', 'os' => 'Solaris', 'adapter' => 'test_adapter', 'foo' => 'bar')}

        include_examples 'node_attributes', {os: 'Solaris', backend: 'Ssh', remote_connection: true}
        include_examples 'run commands', :ssh_helper
      end

      context 'windows os given' do
        let(:subject) {Node.new('test_node', 'os' => 'Windows', 'adapter' => 'test_adapter', 'foo' => 'bar')}

        include_examples 'node_attributes', {os: 'Windows', backend: 'WinRM', remote_connection: true}
        include_examples 'run commands', :winrm_helper
      end
    end
  end
end