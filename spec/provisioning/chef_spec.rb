require 'spec_helper'
require 'nodespec/provisioning/chef'

module NodeSpec
  module Provisioning
    describe Chef do
      describe 'running chef-apply' do
        it_executes_the_provisioning_instructions('chef-apply --opt1 --opt2 -e include_recipe\ \"main::cron\"') do
          chef_apply_execute 'include_recipe "main::cron"', %w[--opt1 --opt2]
        end

        it_executes_the_provisioning_instructions('chef-apply /test\ path/to/recipe --opt1 --opt2') do
          chef_apply_recipe '/test path/to/recipe', %w[--opt1 --opt2]
        end
      end

      describe 'running chef-client' do
        it_executes_the_provisioning_instructions('chef-client -z --opt1 --opt2 -o recipe1,recipe2') do
          chef_client_runlist 'recipe1', 'recipe2', %w[--opt1 --opt2]
        end

        context 'custom configuration' do
          it_executes_the_provisioning_instructions(
            /echo[\\ ]+http_proxy\\ \\\"http:\/\/proxy\.test\.com:3128\\\"'\n'[\\ ]+log_level\\ :info'\n' > nodespec_client.rb/,
            'chef-client -z --opt1 --opt2 -c nodespec_client.rb -o recipe1,recipe2'
          ) do
            chef_client_config <<-EOS
              http_proxy "http://proxy.test.com:3128"
              log_level :info
            EOS
            chef_client_runlist 'recipe1', 'recipe2', %w[--opt1 --opt2]
          end
        end

        context 'custom cookbook path' do
          it_executes_the_provisioning_instructions(
            'echo cookbook_path\ \[\\\'/var/chef/cookbooks\\\',\\\'/var/chef/site-cookbooks\\\'\] > nodespec_client.rb',
            'chef-client -z --opt1 --opt2 -c nodespec_client.rb -o recipe1,recipe2'
          ) do
            set_cookbook_paths '/var/chef/cookbooks', '/var/chef/site-cookbooks'

            chef_client_runlist 'recipe1', 'recipe2', %w[--opt1 --opt2]
          end
        end
      end
    end
  end
end