require 'shellwords'
require 'json'

module NodeSpec
  module Provisioning
    class Chef
      CUSTOM_CLIENT_CONFIG_FILENAME = 'chef_client.rb'
      CUSTOM_ATTRIBUTES_FILENAME = 'chef_client_attributes.json'

      def initialize(node)
        @node = node
        @configuration_entries = []
        @custom_attributes = {}
      end

      def chef_apply_execute(snippet, options = [])
        @node.execute("chef-apply #{options.join(' ')} -e #{snippet.shellescape}")
      end

      def chef_apply_recipe(recipe_file, options = [])
        @node.execute("chef-apply #{recipe_file.shellescape} #{options.join(' ')}")
      end

      def set_cookbook_paths(*paths)
        unless paths.empty?
          paths_in_quotes = paths.map {|p| "'#{p}'"}
          @configuration_entries << %Q(cookbook_path [#{paths_in_quotes.join(",")}])
        end
      end

      def set_attributes(attributes)
        @custom_attributes = attributes
      end

      def chef_client_config(text)
        @configuration_entries << text
      end

      def chef_client_runlist(*args)
        recipes, options = [], []
        recipes << args.take_while {|arg| arg.is_a? String}
        options += args.last if args.last.is_a? Array
        options << configuration_option
        options << attributes_option
        @node.execute("chef-client -z #{options.compact.join(' ')} -o #{recipes.join(',').shellescape}")
      end

      private

      def configuration_option
        unless @configuration_entries.empty?
          config_file = @node.create_file(CUSTOM_CLIENT_CONFIG_FILENAME, @configuration_entries.join("\n"))
          "-c #{config_file}"
        end
      end

      def attributes_option
        unless @custom_attributes.empty?
          attr_file = @node.create_file(CUSTOM_ATTRIBUTES_FILENAME, JSON.generate(@custom_attributes))
          "-j #{attr_file}"
        end
      end
    end
  end
end