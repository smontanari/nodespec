require 'nodespec/node_proxy'

module NodeSpec
  describe NodeProxy do
    let(:node){double('node instance')}
    let(:subject) {Object.new.extend NodeProxy}

    it "runs the command through the node" do
      NodeSpec.stub(current_node: node)
      expect(node).to receive(:execute_command).with('command')

      subject.execute_command('command')
    end

    it "returns the node remote_connection" do
      NodeSpec.stub(current_node: node)
      node.stub(remote_connection: 'connection')

      expect(subject.remote_connection).to eq('connection')
    end
  end
end