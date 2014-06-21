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
  end
end