require 'shellwords'

module NodeSpec
  module Provisioning
    class Shellscript
      def initialize(node)
        @node = node
      end

      def execute_file(path)
        @node.execute_command(path)
      end

      def execute_script(script)
        @node.execute_command("sh -c #{script.shellescape}")
      end
    end
  end
end