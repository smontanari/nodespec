require 'shellwords'

module NodeSpec
  module Provisioning
    class Chef
      CUSTOM_CLIENT_FILENAME = 'nodespec_chef_client.rb'

      def initialize(node)
        @node = node
      end

      def chef_apply_execute(snippet, options = [])
        @node.execute_command("chef-apply #{options.join(' ')} -e #{snippet.shellescape}")
      end

      def chef_apply_recipe(recipe_file, options = [])
        @node.execute_command("chef-apply #{recipe_file.shellescape} #{options.join(' ')}")
      end

      def set_cookbook_paths(*paths)
        unless paths.empty?
          paths_in_quotes = paths.map {|p| "'#{p}'"}
          (@custom_client_configuration ||= "") << %Q(cookbook_path [#{paths_in_quotes.join(",")}])
        end
      end

      def chef_client_config(text)
        (@custom_client_configuration ||= "") << text
      end

      def chef_client_runlist(*args)
        recipes, options = [], []
        recipes << args.take_while {|arg| arg.is_a? String}
        options += args.last if args.last.is_a? Array
        if @custom_client_configuration
          @node.execute_command("echo #{@custom_client_configuration.shellescape} > #{CUSTOM_CLIENT_FILENAME}")
          options << "-c #{CUSTOM_CLIENT_FILENAME}"
        end
        @node.execute_command("chef-client -z #{options.join(' ')} -o #{recipes.join(',').shellescape}")
      end
    end
  end
end