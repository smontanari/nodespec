require 'nodespec/run_options'
require_relative 'timeout_execution'

module NodeSpec
  module CommandHelpers
    class Ssh
      include TimeoutExecution
      ROOT_USER = 'root'

      def initialize(ssh)
        @ssh_session = ssh
      end

      def execute(command)
        command = "sudo #{command}" if @ssh_session.options[:user] != ROOT_USER
        execute_within_timeout(command) do
          success = true
          @ssh_session.exec!(command) do |ch, stream, data|
            verbose_puts(data)
            success = stream != :stderr
          end
          success
        end
      end
    end
  end
end