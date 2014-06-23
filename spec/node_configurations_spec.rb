require 'nodespec/node_configurations'

module NodeSpec
  describe NodeConfigurations do
    before do
      File.stub(exists?: true)
      YAML.stub(:load_file).and_return({
        'test_node1' => { foo: 'bar' },
        'test_node2' => { foo: 'baz' },
        'test_node3' => { foo: 'qaz' }
      })
    end

    describe 'current settings' do
      context 'no options' do
        it 'returns a default Node' do
          allow(Node).to receive(:new).with('node_name', nil).and_return('node_settings')
          expect(NodeConfigurations.instance.get('node_name')).to eq('node_settings')
        end
      end

      context 'configuration name' do
        it 'returns a Node for the given configuration name' do
          allow(Node).to receive(:new).with('node_name', {foo: 'baz'}).and_return('node_settings')
          expect(NodeConfigurations.instance.get('node_name', 'test_node2')).to eq('node_settings')
        end
      end

      context 'configuration hash' do
        it 'returns a Node with the given configuration' do
          allow(Node).to receive(:new).with('node_name', {foo: 'baz'}).and_return('node_settings')
          expect(NodeConfigurations.instance.get('node_name', {foo: 'baz'})).to eq('node_settings')
        end
      end
    end
  end
end