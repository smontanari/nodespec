require 'nodespec/node'

module NodeSpec
  describe Node do
    shared_examples 'node os' do |os|
      it "has the expected os" do
        expect(subject.os).to eq(os)
      end
    end

    shared_examples 'run commands' do
      it "runs a command through the backend proxy" do
        expect(backend_proxy).to receive(:execute).with('test command')
        
        subject.execute('test command')
      end

      it "creates a directory with a path relative to the temporary directory" do
        expect(backend_proxy).to receive(:temp_directory).ordered.and_return('/temp/dir')
        expect(backend_proxy).to receive(:create_directory).ordered.with('/temp/dir/test_dir')
        
        expect(subject.create_temp_directory('test_dir')).to eq('/temp/dir/test_dir')
      end

      it "creates a directory with a path relative to the node working directory" do
        expect(backend_proxy).to receive(:create_directory).ordered.with('.nodespec')
        expect(backend_proxy).to receive(:create_directory).ordered.with('.nodespec/test_dir')
        
        expect(subject.create_directory('test_dir')).to eq('.nodespec/test_dir')
      end

      it "writes to a file with a path relative to the node working directory" do
        expect(backend_proxy).to receive(:create_directory).ordered.with('.nodespec')
        expect(backend_proxy).to receive(:create_file).ordered.with('.nodespec/test/file', 'test content')
        
        expect(subject.create_file('test/file', 'test content')).to eq('.nodespec/test/file')
      end

      it "creates a directory with an absolute path" do
        expect(backend_proxy).to receive(:create_directory).with('/test/dir')
        
        expect(subject.create_directory('/test/dir')).to eq('/test/dir')
      end

      it "writes to a file with an absolute path" do
        expect(backend_proxy).to receive(:create_file).with('/test/file', 'test content')
        
        expect(subject.create_file('/test/file', 'test content')).to eq('/test/file')
      end
    end

    let(:connection) {double('connection')}
    let(:rspec_subject) {double('rspec subject')}
    let(:backend_proxy) {double('backend_proxy')}

    before do
      allow(connection).to receive(:backend_proxy).and_return(backend_proxy)
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

    context 'no adapter' do
      before do
        allow(CommunicationAdapters::NoConnection).to receive(:new).and_return(connection)
      end

      context 'no options' do
        let(:subject) {Node.new('test_node')}

        include_examples 'node os', nil
        include_examples 'run commands'
      end

      context 'options with unix-like os' do
        let(:subject) {Node.new('test_node', 'os' => 'Solaris')}
        
        include_examples 'node os', 'Solaris'
        include_examples 'run commands'
      end

      context 'options with windows os' do
        let(:subject) {Node.new('test_node', 'os' => 'Windows')}

        include_examples 'node os', 'Windows'
        include_examples 'run commands'
      end
    end

    context 'options with adapter' do
      let(:adapter) {double('adapter')}
      before do
        allow(CommunicationAdapters).to receive(:get).with('test_node', 'test_adapter', 'foo' => 'bar').and_return(adapter)
        allow(adapter).to receive(:connection).and_return(connection)
        allow(connection).to receive(:session).and_return('remote session')
      end

      context 'no os given' do
        let(:subject) {Node.new('test_node', 'adapter' => 'test_adapter', 'foo' => 'bar')}

        include_examples 'node os', nil
        include_examples 'run commands'
      end

      context 'unix-like os given' do
        let(:subject) {Node.new('test_node', 'os' => 'Solaris', 'adapter' => 'test_adapter', 'foo' => 'bar')}

        include_examples 'node os', 'Solaris'
        include_examples 'run commands'
      end

      context 'windows os given' do
        let(:subject) {Node.new('test_node', 'os' => 'Windows', 'adapter' => 'test_adapter', 'foo' => 'bar')}

        include_examples 'node os', 'Windows'
        include_examples 'run commands'
      end
    end
  end
end