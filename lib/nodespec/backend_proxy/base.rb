require 'nodespec/verbose_output'
require 'nodespec/command_execution'

module NodeSpec
  module BackendProxy
    class Base
      include CommandExecution

      [:create_directory, :create_file].each do |m|
        define_method(m) do |*args|
          execute(send("cmd_#{m}", *args))
        end
      end

      def execute(command)
        raise "You must subclass #{self.class} and implement #execute"
      end
    end
  end
end