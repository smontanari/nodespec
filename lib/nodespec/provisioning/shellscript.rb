require 'shellwords'

module NodeSpec
  module Provisioning
    class Shellscript
      def initialize(node)
        @node = node
      end

      def execute_file(path)
        @node.execute(path)
      end

      def execute_script(script)
        @node.execute("sh -c #{script.shellescape}")
      end
    end
  end
end