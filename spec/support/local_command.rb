module NodeSpec
  module RSpecExtensions
    def it_executes_the_local_command(*command_matches, &instructions)
      it 'runs the commands' do
        command_matches.each do |command_match|
          expect(subject).to receive(:run_command).with(command_match)
        end
        subject.instance_eval(&instructions)
      end
    end
  end
end
