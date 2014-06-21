module NodeSpec
  module NodeProxy
    def execute_command(command)
      NodeSpec.current_node.execute_command(command)
    end
  end
end