require 'specinfra/helper'
require 'nodespec/communication_adapters'
require 'nodespec/communication_adapters/native_communicator'

module NodeSpec
  class Node
    class BadNodeNameError < StandardError; end

    WORKING_DIR = '.nodespec'
    attr_reader :os, :communicator, :name

    def initialize(node_name, options = nil)
      @name = validate(node_name)
      opts = (options || {}).dup
      @os = opts.delete('os')
      @communicator = init_communicator(node_name, opts)
    end

    def backend
      @communicator.backend(@os)
    end

    [:create_directory, :create_file].each do |met|
      define_method(met) do |*args|
        path_argument = args.shift
        unless path_argument.start_with?('/')
          backend_proxy.create_directory WORKING_DIR
          path_argument = "#{WORKING_DIR}/#{path_argument}"
        end
        backend_proxy.send(met, path_argument, *args)
        path_argument
      end
    end

    def create_temp_directory(path)
      path = path[1..-1] if path.start_with?('/')
      create_directory("#{backend_proxy.temp_directory}/#{path}")
    end

    def execute(command)
      backend_proxy.execute(command)
    end

    private

    def backend_proxy
      @backend_proxy ||= @communicator.backend_proxy(@os)
    end

    def validate(name)
      raise BadNodeNameError.new unless name =~ /^[a-zA-Z0-9][a-zA-Z0-9. \-_]+\s*$/
      name.strip.gsub(' ', '-')
    end

    def init_communicator(node_name, options)
      adapter_name = options.delete('adapter')
      if adapter_name
        CommunicationAdapters.get(node_name, adapter_name, options).communicator
      else
        CommunicationAdapters::NativeCommunicator.new
      end
    end
  end
end