require 'nodespec/command_execution'
require_relative 'base'

module NodeSpec
  module BackendProxy
    class WinRM < Base
      def initialize(winrm)
        @winrm_session = winrm
      end

      def execute command
        result = @winrm_session.powershell(command)
        stdout, stderr = [:stdout, :stderr].map do |s|
          result[:data].select {|item| item.key? s}.map {|item| item[s]}.join
        end
        [stdout, stderr].each {|s| verbose_puts s}
        result[:exitcode] == 0 and stderr.empty?
      end
    end
  end
end