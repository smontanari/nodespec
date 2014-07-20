require 'net/ssh'
require 'nodespec/verbose_output'
require_relative 'remote_backend'

module NodeSpec
  module CommunicationAdapters
    class SshCommunicator
      include VerboseOutput
      include RemoteBackend
      attr_reader :session, :os

      def initialize(host, os = nil, options = {})
        @host = host
        @os = os
        @ssh_options = Net::SSH.configuration_for(@host)
        @user = options['user'] || @ssh_options[:user]
        %w[port password keys].each do |param|
          @ssh_options[param.to_sym] = options[param] if options[param]
        end
      end

      def bind_to(configuration)
        current_session = configuration.ssh
        if current_session && (current_session.host != @host || current_session.options[:port] != @ssh_options[:port])
          msg = "\nClosing connection to #{current_session.host}"
          msg << ":#{current_session.options[:port]}" if current_session.options[:port]
          verbose_puts msg
          current_session.close
        end
        if current_session.nil? || current_session.closed?
          msg = "\nConnecting to #{@host}"
          msg << ":#{@ssh_options[:port]}" if @ssh_options[:port]
          msg << " as #{@user}..."
          verbose_puts msg
          current_session = Net::SSH.start(@host, @user, @ssh_options)
          configuration.host = @host
          configuration.ssh = current_session
        end
        @session = current_session
      end
    end
  end
end