require 'nodespec/verbose_output'

module NodeSpec
  class ConfigurationBinding
    include VerboseOutput

    def initialize(configuration)
      @configuration = configuration
    end

    def bind_ssh_session_for(host, port)
      current_session = @configuration.ssh
      if current_session.nil? || current_session.host != host || current_session.options[:port] != port
        unbind_ssh_session
        current_session = yield
        @configuration.ssh = current_session
        @configuration.ssh_options = current_session.options
        @configuration.host = current_session.host
      end
      current_session
    end

    def bind_winrm_session_for(host, endpoint)
      current_session = @configuration.winrm
      if current_session.nil? || current_session.endpoint != endpoint
        unbind_winrm_session
        current_session = yield
        @configuration.winrm = current_session
        @configuration.host = host
      end
      current_session
    end

    def unbind_ssh_session
      if @configuration.ssh
        msg = "\nClosing connection to #{@configuration.ssh.host}"
        msg << ":#{@configuration.ssh.options[:port]}" if @configuration.ssh.options[:port]
        verbose_puts msg
        @configuration.ssh.close
      end
      @configuration.ssh = @configuration.ssh_options = @configuration.host =nil
    end

    def unbind_winrm_session
      @configuration.winrm = @configuration.host = nil
    end
  end
end