require 'nodespec/verbose_output'

module NodeSpec
  class ConfigurationBinding
    include VerboseOutput

    BACKEND_ACTIONS = {
      ssh: {
        diff_session: lambda { |ssh, params| ssh.host != params[:host] || ssh.options[:port] != params[:port] },
        bind_attributes: lambda { |ssh, config| config.ssh_options = ssh.options }
      },
      winrm: {
        diff_session: lambda { |winrm, params| winrm.endpoint != params[:endpoint] }
      }
    }

    def initialize(configuration)
      @configuration = configuration
    end

    BACKEND_ACTIONS.keys.each do |backend|
      define_method("bind_#{backend}_session_for") do |params, &block|
        bind_session_for(backend, params, &block)
      end
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
      verbose_puts "\nClosing connection to #{@configuration.winrm.endpoint}" if @configuration.winrm
      @configuration.winrm = @configuration.host = nil
    end

    private

    def bind_session_for(backend, params)
      current_session = @configuration.send(backend)
      if current_session.nil? || BACKEND_ACTIONS[backend][:diff_session].call(current_session, params)
        send("unbind_#{backend}_session")
        current_session = yield
        @configuration.send("#{backend}=", current_session)
        @configuration.host = params[:host]
        BACKEND_ACTIONS[backend][:bind_attributes].call(current_session, @configuration) if BACKEND_ACTIONS[backend][:bind_attributes]
      end
      current_session
    end
  end
end