module NodeSpec
  module RSpecExtensions
    def it_executes_the_provisioning_instructions(*command_matches, &provisioning_instructions)
      it 'runs the commands' do
        command_matches.each do |command_match|
          expect(subject).to receive(:execute_command).with(command_match)
        end
        subject.instance_eval(&provisioning_instructions)
      end
    end
  end
end
