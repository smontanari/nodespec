require 'net/ssh'
require 'nodespec/ssh_connection'

module NodeSpec
  module ConnectionAdapters
    class Ssh
      attr_reader :connection

      def initialize(node_name, options = {})
        host = options['host'] || node_name
        ssh_options = Net::SSH.configuration_for(host)
        user = options['username'] || ssh_options[:user]
        %w[port password keys].each do |param|
          ssh_options[param.to_sym] = options[param] if options[param]
        end
        @connection = SshConnection.new(host, user, ssh_options)
      end
    end
  end
end
