shared_context 'initialize with current node', init_with_current_node: true do
  let(:current_node) {double('current node')}
  let(:subject) {described_class.new(current_node)}
end