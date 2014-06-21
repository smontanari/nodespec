require 'shellwords'
require 'nodespec/node_proxy'

module NodeSpec
  module Provisioning
    class Chef
      include NodeProxy
      CUSTOM_CLIENT_FILENAME = 'nodespec_client.rb'

      def chef_apply_execute(snippet, options = [])
        execute_command("chef-apply #{options.join(' ')} -e #{snippet.shellescape}")
      end

      def chef_apply_recipe(recipe_file, options = [])
        execute_command("chef-apply #{recipe_file.shellescape} #{options.join(' ')}")
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
        recipes = args.select {|a| a.is_a? String}
        options = args.select {|a| a.is_a? Array}
        if @custom_client_configuration
          execute_command("echo #{@custom_client_configuration.shellescape} > #{CUSTOM_CLIENT_FILENAME}")
          options << "-c #{CUSTOM_CLIENT_FILENAME}"
        end
        execute_command("chef-client -z #{options.join(' ')} -o #{recipes.join(',').shellescape}")
      end
    end
  end
end