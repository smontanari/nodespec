require 'net/ssh'
require_relative 'verbose_output'

module NodeSpec
  class SshConnection
    include VerboseOutput
    attr_reader :session

    def initialize(options)
      @host = options['host']
      @ssh_options = Net::SSH.configuration_for(@host)
      @user = options['user'] || @ssh_options[:user]
      %w[port password keys].each do |param|
        @ssh_options[param.to_sym] = options[param] if options[param]
      end
    end

    def bind_to(configuration)
      current_session = configuration.ssh
      if current_session && (current_session.host != @host || current_session.options[:port] != @ssh_options[:port])
        verbose_puts "\nClosing connection to #{configuration.ssh.host}:#{configuration.ssh.options[:port]}"
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