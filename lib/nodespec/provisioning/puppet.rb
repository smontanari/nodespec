require 'yaml'
require 'shellwords'
require 'erb'

module NodeSpec
  module Provisioning
    class Puppet
      HIERADATA_DIRNAME = 'puppet_hieradata'
      HIERA_CONFIG_FILENAME = 'puppet_hiera.yaml'
      HIERA_DEFAULT_HIERARCHY = 'common'
      HIERA_CONFIG_TEMPLATE = <<-EOS
:backends:
  - yaml
:yaml:
  :datadir: <%= hieradata_dir %>
:hierarchy:
  - #{HIERA_DEFAULT_HIERARCHY}
EOS
      def initialize(node)
        @node = node
      end

      def set_modulepaths(*paths)
        @modulepath_option = "--modulepath #{paths.join(':').shellescape}" unless paths.empty?
      end

      def set_facts(facts)
        @facts = facts.reduce("") { |fact, pair| "FACTER_#{pair[0]}=#{pair[1].shellescape} #{fact}" }
      end

      def set_hieradata(values)
        unless values.empty?
          hieradata_dir = @node.create_directory(HIERADATA_DIRNAME)
          @node.create_file("#{HIERADATA_DIRNAME}/#{HIERA_DEFAULT_HIERARCHY}.yaml", YAML.dump(values))
          hiera_config = @node.create_file(HIERA_CONFIG_FILENAME, ERB.new(HIERA_CONFIG_TEMPLATE).result(binding))
          @hiera_option = "--hiera_config #{hiera_config}"
        end
      end

      def puppet_apply_execute(snippet, options = [])
        @node.execute("#{group_command_options(options)} -e #{snippet.shellescape}")
      end

      def puppet_apply_manifest(manifest_file, options = [])
        @node.execute("#{group_command_options(options)} #{manifest_file.shellescape}")
      end

      private

      def group_command_options(options)
        %Q[#{@facts}puppet apply #{@modulepath_option} #{@hiera_option} #{options.join(' ')}]
      end
    end
  end
end