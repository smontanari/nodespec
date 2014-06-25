require 'shellwords'

module NodeSpec
  module Provisioning
    class Chef
      CUSTOM_CLIENT_FILENAME = 'chef_client.rb'

      def initialize(node)
        @node = node
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

      def chef_client_config(text)
        @configuration_entries << text
      end

      def chef_client_runlist(*args)
        recipes, options = [], []
        recipes << args.take_while {|arg| arg.is_a? String}
        options += args.last if args.last.is_a? Array
        unless @configuration_entries.empty?
          config_file = @node.create_file(CUSTOM_CLIENT_FILENAME, @configuration_entries.join("\n"))
          options << "-c #{config_file}"
        end
        @node.execute("chef-client -z #{options.join(' ')} -o #{recipes.join(',').shellescape}")
      end
    end
  end
end