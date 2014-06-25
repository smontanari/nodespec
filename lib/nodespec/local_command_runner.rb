require 'open3'
require 'nodespec/run_options'
require 'nodespec/command_execution'

module NodeSpec
  module LocalCommandRunner
    include CommandExecution

    def run_command command
      execute_within_timeout(command) do
        output, status = Open3.capture2e(command)
        verbose_puts(output)
        status.success?
      end
    end
  end
end