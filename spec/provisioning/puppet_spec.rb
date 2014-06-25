require 'spec_helper.rb'
require 'nodespec/provisioning/puppet'

module NodeSpec
  module Provisioning
    describe Puppet, init_with_current_node: true do
      describe 'executing a puppet inline code' do
        it_executes_the_node_command(/^puppet apply\s+ --opt1 --opt2 -e include\\ testmodule::testclass$/) do
          puppet_apply_execute 'include testmodule::testclass', %w[--opt1 --opt2]
        end
      end

      describe 'executing a puppet manifest file' do
        it_executes_the_node_command(/^puppet apply .* \/test\/path\\ to\/manifest$/) do
          puppet_apply_manifest '/test/path to/manifest'
        end
      end

      describe 'setting facts' do
        it_executes_the_node_command(/^FACTER_foo=bar\\ baz puppet apply .*$/) do
          set_facts 'foo' => 'bar baz'
          puppet_apply_manifest '/test/path/to/manifest'
        end
      end

      describe 'setting the module path' do
        it_executes_the_node_command(/puppet apply --modulepath \/test\\ path\/1:\/test\\ path\/2 .*/) do
          set_modulepaths '/test path/1', '/test path/2'
          puppet_apply_execute 'include testmodule::testclass'
        end
      end

      describe 'setting hiera data' do
        it_executes_the_node_command(
          'mkdir -p nodespec_puppet_hieradata',
          %Q[sh -c "echo ---'\n'test:\\ hiera\\ data'\n' > nodespec_puppet_hieradata/nodespec_current.yaml"],
          %Q[sh -c "echo :backends:'\n'\\ \\ -\\ yaml'\n':yaml:'\n'\\ \\ :datadir:\\ nodespec_puppet_hieradata'\n':hierarchy:'\n'\\ \\ -\\ nodespec_current'\n' > nodespec_puppet_hiera.yaml"],
          'puppet apply --modulepath /test/module/path --hiera_config nodespec_puppet_hiera.yaml --opts /test/path/to/manifest'
        ) do
          set_modulepaths '/test/module/path'
          set_hieradata('test' => 'hiera data')

          puppet_apply_manifest '/test/path/to/manifest', %w[--opts]
        end
      end

      describe 'setting hiera config' do
      end
    end
  end
end