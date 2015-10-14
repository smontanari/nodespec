module RSpec::Core::Notifications
  class FailedExampleNotification < ExampleNotification
    def failure_lines
      host = example.metadata[:nodespec]["host"]
      @failure_lines ||=
        begin
          lines = []
          lines << "On host `#{host}'" if host
          lines << "Failure/Error: #{read_failed_line.strip}"
          lines << "#{exception_class_name}:" unless exception_class_name =~ /RSpec/
          exception.message.to_s.split("\n").each do |line|
            lines << "  #{line}" if exception.message
          end
          lines << "  #{example.metadata[:command]}"
          lines << "  #{example.metadata[:stdout]}" if example.metadata[:stdout]
          lines << "  #{example.metadata[:stderr]}" if example.metadata[:stderr]
          lines
        end
    end
  end
end