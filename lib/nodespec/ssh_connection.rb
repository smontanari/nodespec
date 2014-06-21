require 'net/ssh'
require_relative 'verbose_output'

module NodeSpec
  class SshConnection
    include VerboseOutput
    attr_reader :session

    def initialize(host, user, options)
      @host = host
      @user = user
      @options = options
    end

    def bind(configuration)
      configuration.ssh.close if configuration.ssh && configuration.host != @host
      if configuration.ssh.nil? || configuration.ssh.closed?
        configuration.host = @host
        verbose_puts "Connecting to #{@host} as #{@user}..."
        configuration.ssh = Net::SSH.start(@host, @user, @options)
      end
      @session = configuration.ssh
    end
  end
end