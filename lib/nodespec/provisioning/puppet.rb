require 'yaml'
require 'shellwords'

module NodeSpec
  module Provisioning
    class Puppet
      HIERA_CONFIG = <<-eos
:backends:
  - yaml
:yaml:
  :datadir: nodespec_puppet_hieradata
:hierarchy:
  - nodespec_current
eos
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
          @node.execute_command 'mkdir -p nodespec_puppet_hieradata'
          @node.execute_command %Q[sh -c "echo #{YAML.dump(values).shellescape} > nodespec_puppet_hieradata/nodespec_current.yaml"]
          @node.execute_command %Q[sh -c "echo #{HIERA_CONFIG.shellescape} > nodespec_puppet_hiera.yaml"]
          @hiera_option = '--hiera_config nodespec_puppet_hiera.yaml'
        end
      end

      def puppet_apply_execute(snippet, options = [])
        @node.execute_command("#{group_command_options(options)} -e #{snippet.shellescape}")
      end

      def puppet_apply_manifest(manifest_file, options = [])
        @node.execute_command("#{group_command_options(options)} #{manifest_file.shellescape}")
      end

      private



      def group_command_options(options)
        %Q[#{@facts}puppet apply #{@modulepath_option} #{@hiera_option} #{options.join(' ')}]
      end
    end
  end
end