require 'nodespec/command_execution'

module NodeSpec
  module BackendProxy
    class Ssh
      include CommandExecution
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