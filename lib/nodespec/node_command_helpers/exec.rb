require 'open3'
require 'nodespec/run_options'
require 'nodespec/timeout_execution'

module NodeSpec
  module NodeCommandHelpers
    class Exec
      include TimeoutExecution

      def execute command
        command = "sudo #{command}" if NodeSpec::RunOptions.run_local_with_sudo?
        execute_within_timeout(command) do
          output, status = Open3.capture2e(command)
          verbose_puts(output)
          status.success?
        end
      end
    end
  end
end