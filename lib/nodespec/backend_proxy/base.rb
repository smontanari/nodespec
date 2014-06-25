require 'nodespec/verbose_output'

module NodeSpec
  module BackendProxy
    class CommandExecutionError < StandardError; end
    class Base
      include VerboseOutput

      [:create_directory, :create_file].each do |m|
        define_method(m) do |*args|
          execute(send("cmd_#{m}", *args))
        end
      end

      def execute_within_timeout(command, timeout = NodeSpec::RunOptions.command_timeout, &block)
        verbose_puts "\nExecuting command:\n#{command}"
        command_success = Timeout::timeout(timeout, &block)
        raise CommandExecutionError.new 'The command execution failed. Enable verbosity to check the output.' unless command_success
      end

      def execute(command)
        raise "You must subclass #{self.class} and implement #execute"
      end
    end
  end
end