require 'nodespec/node_configurations'

module NodeSpec
  describe NodeConfigurations do
    before do
      allow(File).to receive(:exists?).and_return(true)
      allow(YAML).to receive(:load_file).and_return({
        'test_node1' => { foo: 'bar' },
        'test_node2' => { foo: 'baz' },
        'test_node3' => { foo: 'qaz' }
      })
    end

    describe 'current settings' do
      context 'anything but string or hash' do
        before do
          allow(Node).to receive(:new).with('node_name', {}).and_return('node')
        end
        [nil, true, 1, [], Object.new].each do |options|
          it 'returns a default Node' do
            expect(NodeConfigurations.instance.get('node_name')).to eq('node')
          end
        end
      end

      context 'configuration name' do
        it 'returns a Node for the given configuration name' do
          allow(Node).to receive(:new).with('node_name', {foo: 'baz'}).and_return('node')
          expect(NodeConfigurations.instance.get('node_name', 'test_node2')).to eq('node')
        end
      end

      context 'configuration hash' do
        it 'returns a Node with the given configuration' do
          allow(Node).to receive(:new).with('node_name', {foo: 'baz'}).and_return('node')
          expect(NodeConfigurations.instance.get('node_name', {foo: 'baz'})).to eq('node')
        end
      end
    end
  end
end