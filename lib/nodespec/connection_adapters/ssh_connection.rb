require 'net/ssh'
require 'nodespec/verbose_output'
require_relative 'remote'

module NodeSpec
  module ConnectionAdapters
    class SshConnection
      include VerboseOutput
      include Remote
      attr_reader :session

      def initialize(host, options)
        @host = host
        @ssh_options = Net::SSH.configuration_for(@host)
        @user = options['user'] || @ssh_options[:user]
        %w[port password keys].each do |param|
          @ssh_options[param.to_sym] = options[param] if options[param]
        end
      end

      def bind_to(configuration)
        current_session = configuration.ssh
        if current_session && (current_session.host != @host || current_session.options[:port] != @ssh_options[:port])
          msg = "\nClosing connection to #{configuration.ssh.host}"
          msg << ":#{configuration.ssh.options[:port]}" if configuration.ssh.options[:port]
          verbose_puts msg
          current_session.close
        end
        if current_session.nil? || current_session.closed?
          verbose_puts "\nConnecting to #{@host}:#{@ssh_options[:port]} as #{@user}..."
          current_session = Net::SSH.start(@host, @user, @ssh_options)
          configuration.host = @host
          configuration.ssh = current_session
        end
        @session = current_session
      end
    end
  end
end