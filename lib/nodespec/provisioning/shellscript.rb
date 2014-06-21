require 'shellwords'
require 'nodespec/node_proxy'

module NodeSpec
  module Provisioning
    class Shellscript
      include NodeProxy

      def execute_file(path)
        execute_command(path)
      end

      def execute_script(script)
        execute_command("sh -c #{script.shellescape}")
      end
    end
  end
end