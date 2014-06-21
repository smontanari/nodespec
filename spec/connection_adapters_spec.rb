require 'nodespec/connection_adapters'

module NodeSpec
  describe ConnectionAdapters do
    it "returns a Vagrant adapter" do
      expect(Adapters::Vagrant).to receive(:new).with('test_node', 'adapter_options' => 'test_options').and_return('adapter')

      adapter = ConnectionAdapters.get('test_node', 'vagrant', 'adapter_options' => 'test_options')

      expect(adapter).to eq('adapter')
    end

    it "returns a Ssh adapter" do
      expect(Adapters::Ssh).to receive(:new).with('test_node', 'adapter_options' => 'test_options').and_return('adapter')

      adapter = ConnectionAdapters.get('test_node', 'ssh', 'adapter_options' => 'test_options')

      expect(adapter).to eq('adapter')
    end
  end
end