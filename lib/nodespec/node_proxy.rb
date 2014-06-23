module NodeSpec
  module NodeProxy
    [:execute_command, :remote_connection].each do |m|
      define_method(m) {|*args| NodeSpec.current_node.send(m, *args)}
    end
  end
end