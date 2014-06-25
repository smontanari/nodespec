require_relative 'base'
require_relative 'unixshell_utility'

module NodeSpec
  module BackendProxy
    class Ssh < Base
      include UnixshellUtility
      
      ROOT_USER = 'root'

      def initialize(ssh)
        @ssh_session = ssh
      end

      def execute(command)
        command = run_as_sudo(command) if @ssh_session.options[:user] != ROOT_USER
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