require 'shellwords'
require 'json'

module NodeSpec
  module Provisioning
    class Chef
      CLIENT_CONFIG_FILENAME = 'chef_client.rb'
      ATTRIBUTES_FILENAME = 'chef_client_attributes.json'
      NODES_DIRNAME = 'chef_nodes'

      def initialize(node)
        @node = node
        @custom_attributes = {}
        @configuration_entries = []
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
        run_list_items, options = [], []
        run_list_items << args.take_while {|arg| arg.is_a? String}
        options += args.last if args.last.is_a? Array
        options << configuration_option
        options << attributes_option
        @node.execute("chef-client -z #{options.compact.join(' ')} -o #{run_list_items.join(',').shellescape}")
      end

      private

      def configuration_option
        unless @configuration_entries.any? {|c| c =~ /^node_path .+$/}
          nodes_directory = @node.create_temp_directory(NODES_DIRNAME)
          @configuration_entries.unshift("node_path '#{nodes_directory}'")
        end
        # puts @configuration_entries.join("\n")
        config_file = @node.create_file(CLIENT_CONFIG_FILENAME, @configuration_entries.join("\n"))
        "-c #{config_file}"
      end

      def attributes_option
        unless @custom_attributes.empty?
          attr_file = @node.create_file(ATTRIBUTES_FILENAME, JSON.generate(@custom_attributes))
          "-j #{attr_file}"
        end
      end
    end
  end
end