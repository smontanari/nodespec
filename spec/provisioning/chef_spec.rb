require 'spec_helper'
require 'nodespec/provisioning/chef'

module NodeSpec
  module Provisioning
    describe Chef, init_with_current_node: true do
      describe 'running chef-apply' do
        it_executes_the_node_command('chef-apply --opt1 --opt2 -e include_recipe\ \"main::cron\"') do
          chef_apply_execute 'include_recipe "main::cron"', %w[--opt1 --opt2]
        end

        it_executes_the_node_command('chef-apply /test\ path/to/recipe --opt1 --opt2') do
          chef_apply_recipe '/test path/to/recipe', %w[--opt1 --opt2]
        end
      end

      describe 'running chef-client' do
        context 'specified node path' do
          describe 'custom configuration' do
            before do
              expect(current_node).to receive(:create_file).with('chef_client.rb', "node_path '/path/to/nodes'").ordered.and_return('config/chef_client.rb')
            end

            it_executes_the_node_command(
              'chef-client -z --opt1 --opt2 -c config/chef_client.rb -o recipe1,recipe2'
            ) do
              chef_client_config "node_path '/path/to/nodes'"
              chef_client_runlist 'recipe1', 'recipe2', %w[--opt1 --opt2]
            end
          end
        end

        context 'implicit node path' do
          before do
            expect(current_node).to receive(:create_temp_directory).with('chef_nodes').and_return('/tmp/dir/chef_nodes')
            allow(current_node).to receive(:create_file).with('chef_client.rb', /^node_path '\/tmp\/dir\/chef_nodes'$/).and_return('config/chef_client.rb')
          end

          it_executes_the_node_command('chef-client -z --opt1 --opt2 -c config/chef_client.rb -o recipe1,recipe2') do
            chef_client_runlist 'recipe1', 'recipe2', %w[--opt1 --opt2]
          end

          describe 'custom configuration' do
            before do
              expect(current_node).to receive(:create_file).with('chef_client.rb', /^test config$/).ordered.and_return('config/chef_client.rb')
            end

            it_executes_the_node_command(
              'chef-client -z --opt1 --opt2 -c config/chef_client.rb -o recipe1,recipe2'
            ) do
              chef_client_config 'test config'
              chef_client_runlist 'recipe1', 'recipe2', %w[--opt1 --opt2]
            end
          end

          describe 'custom cookbook path' do
            before do
              expect(current_node).to receive(:create_file).with('chef_client.rb', /^cookbook_path \['\/var\/chef\/cookbooks','\/var\/chef\/site-cookbooks'\]$/).ordered.and_return('config/chef_client.rb')
            end

            it_executes_the_node_command(
              'chef-client -z --opt1 --opt2 -c config/chef_client.rb -o recipe1,recipe2'
            ) do
              set_cookbook_paths '/var/chef/cookbooks', '/var/chef/site-cookbooks'

              chef_client_runlist 'recipe1', 'recipe2', %w[--opt1 --opt2]
            end
          end

          describe 'setting custom attributes' do
            before do
              expect(current_node).to receive(:create_file).with('chef_client_attributes.json', %q[{"test_attributes":{"attr1":"foo","attr2":"bar"}}]).ordered.and_return('config/chef_client_attributes.json')
            end

            it_executes_the_node_command(
              'chef-client -z -c config/chef_client.rb -j config/chef_client_attributes.json -o recipe1,recipe2'
            ) do
              set_attributes test_attributes: {attr1: 'foo', attr2: 'bar'}

              chef_client_runlist 'recipe1', 'recipe2'
            end
          end
        end
      end
    end
  end
end