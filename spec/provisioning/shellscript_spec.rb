require 'spec_helper'
require 'nodespec/provisioning/shellscript'

module NodeSpec
  module Provisioning
    describe Shellscript do
      it_executes_the_node_command('/path/to/test/script.sh') do
        execute_file('/path/to/test/script.sh')
      end
      it_executes_the_node_command("sh -c mkdir\\ /tmp/test_dir'\n'cd\\ /tmp/test_dir'\n'touch\\ test.txt'\n'") do
        execute_script <<-EOS
mkdir /tmp/test_dir
cd /tmp/test_dir
touch test.txt
        EOS
      end
    end
  end
end