require 'open3'
require 'nodespec/run_options'
require_relative 'base'
require_relative 'unixshell_utility'

module NodeSpec
  module BackendProxy
    class Exec < Base
      include UnixshellUtility

      def execute command
        command = run_as_sudo(command) if NodeSpec::RunOptions.run_local_with_sudo?
        execute_within_timeout(command) do
          output, status = Open3.capture2e(command)
          verbose_puts(output)
          status.success?
        end
      end
    end
  end
end