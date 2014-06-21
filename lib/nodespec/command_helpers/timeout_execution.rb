require 'timeout'
require 'nodespec/verbose_output'
require 'nodespec/run_options'

module NodeSpec
  module CommandHelpers
    module TimeoutExecution
      include VerboseOutput

      def execute_within_timeout(command, timeout = NodeSpec::RunOptions.command_timeout, &block)
        verbose_puts "\nExecuting command:\n#{command}"
        command_success = Timeout::timeout(timeout, &block)
        raise 'The command execution failed. Enable verbosity to check the output.' unless command_success
      end
    end
  end
end