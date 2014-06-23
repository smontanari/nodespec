require 'spec_helper.rb'
require 'nodespec/provisioning/puppet'

module NodeSpec
  module Provisioning
    describe Puppet, init_with_current_node: true do
      describe 'executing a puppet inline code' do
        it_executes_the_node_command('FACTER_foo=bar\ baz puppet apply --modulepath /test\ path/1:/test\ path/2 --opt1 --opt2 -e include\ testmodule::testclass') do
          set_modulepaths '/test path/1', '/test path/2'
          set_facts 'foo' => 'bar baz'
          puppet_apply_execute 'include testmodule::testclass', %w[--opt1 --opt2]
        end
      end

      describe 'executing a puppet manifest file' do
        it_executes_the_node_command('FACTER_foo=bar\ baz puppet apply --modulepath /test\ path/1:/test\ path/2 --opt1 --opt2 /test/path/to/manifest') do
          set_modulepaths '/test path/1', '/test path/2'
          set_facts 'foo' => 'bar baz'
          puppet_apply_manifest '/test/path/to/manifest', %w[--opt1 --opt2]
        end
      end
    end
  end
end