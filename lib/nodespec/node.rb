require 'specinfra/helper'
require 'nodespec/connection_adapters'
require 'nodespec/backends'

module NodeSpec
  class Node
    class BadNodeNameError < StandardError; end

    WORKING_DIR = '.nodespec'
    attr_reader :os, :remote_connection, :name

    def initialize(node_name, options = nil)
      @name = validate(node_name)
      options = (options || {}).dup
      @os = options.delete('os')
      adapter_name = options.delete('adapter')
      if adapter_name
        adapter = ConnectionAdapters.get(node_name, adapter_name, options)
        @remote_connection = adapter.connection
      end
    end

    def backend
      if @remote_connection
        remote_backend
      else
        local_backend
      end
    end

    [:create_directory, :create_file].each do |met|
      define_method(met) do |*args|
        path_argument = args.shift
        path = path_argument.start_with?('/') ? path_argument : "#{WORKING_DIR}/#{path_argument}"
        backend_proxy.send(met, path, *args)
        path
      end
    end

    def execute(command)
      backend_proxy.execute(command)
    end

    private

    def backend_proxy
      @backend_proxy ||= init_backend_proxy
    end

    def init_backend_proxy
      if @remote_connection
        BackendProxy.const_get(remote_backend).new(@remote_connection.session)
      else
        BackendProxy.const_get(local_backend).new
      end
    end

    def local_backend
      @os == 'Windows' ? Backends::Cmd : Backends::Exec
    end

    def remote_backend
      @os == 'Windows' ? Backends::WinRM : Backends::Ssh
    end

    def validate(name)
      raise BadNodeNameError.new unless name =~ /^[a-zA-Z0-9][a-zA-Z0-9. \-_]+\s*$/
      name.strip.gsub(' ', '-')
    end
  end
end