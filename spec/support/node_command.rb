module NodeSpec
  module RSpecExtensions
    def it_executes_the_node_command(*command_matches, &provisioning_instructions)
      it 'runs the commands' do
        command_matches.each do |command_match|
          expect(current_node).to receive(:execute).with(command_match)
        end
        subject.instance_eval(&provisioning_instructions)
      end
    end
  end
end
