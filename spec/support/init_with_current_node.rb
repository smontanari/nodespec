shared_context 'initialize with current node', init_with_current_node: true do |eg|
  let(:current_node) {double('current node')}
  let(:subject) {self.class.const_get(eg.description).new(current_node)}
end