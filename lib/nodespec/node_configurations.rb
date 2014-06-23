require 'yaml'
require 'singleton'
require_relative 'node'

module NodeSpec
  class NodeConfigurations
    include Singleton
    attr_reader :current_settings

    def initialize
      filename = ENV['NODESPEC_CONFIG'] || 'nodespec_config.yml'
      data = YAML.load_file(filename) if File.exists?(filename)
      @predefined_settings = data || {}
    end

    def get(node_name, options = nil)
      if options.is_a? String
        raise "Cannot find nodespec settings '#{options}'" unless @predefined_settings.key?(options)
        opts = @predefined_settings[options]
      else
        opts = options
      end
      Node.new(node_name, opts)
    end
  end
end