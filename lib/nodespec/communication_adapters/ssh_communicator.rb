require 'net/ssh'
require 'nodespec/verbose_output'
require 'nodespec/backend_proxy'

module NodeSpec
  module CommunicationAdapters
    class SshCommunicator
      include VerboseOutput
      attr_reader :session

      def initialize(host, options = {})
        @host = host
        @ssh_options = Net::SSH.configuration_for(@host)
        @user = options['user'] || @ssh_options[:user]
        %w[port password keys].each do |param|
          @ssh_options[param.to_sym] = options[param] if options[param]
        end
      end

      def bind_to(configuration)
        configuration.winrm = nil if configuration.winrm
        current_session = configuration.ssh

        close_ssh_session(current_session) if current_session && (current_session.host != @host || current_session.options[:port] != @ssh_options[:port])

        if current_session.nil? || current_session.closed?
          current_session = start_new_ssh_session
          configuration.host = @host
          configuration.ssh = current_session
          configuration.ssh_options = current_session.options
        end
        @session = current_session
      end

      def backend_proxy
        BackendProxy.create(:ssh, @session)
      end

      def backend
        :ssh
      end

      private

      def close_ssh_session(session)
        msg = "\nClosing connection to #{session.host}"
        msg << ":#{session.options[:port]}" if session.options[:port]
        verbose_puts msg
        session.close
      end

      def start_new_ssh_session
        msg = "\nConnecting to #{@host}"
        msg << ":#{@ssh_options[:port]}" if @ssh_options[:port]
        msg << " as #{@user}..."
        verbose_puts msg
        Net::SSH.start(@host, @user, @ssh_options)
      end
    end
  end
end