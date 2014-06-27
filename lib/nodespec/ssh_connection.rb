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
      configuration.ssh.close if configuration.ssh && configuration.host != @host
      if configuration.ssh.nil? || configuration.ssh.closed?
        configuration.host = @host
        verbose_puts "Connecting to #{@host} as #{@user}..."
        configuration.ssh = Net::SSH.start(@host, @user, @ssh_options)
      end
      @session = configuration.ssh
    end
  end
end