module NodeSpec
  module RunOptions
    class << self
      [:verbose, :run_local_with_sudo].each do |attr|
        attr_accessor attr
        alias_method("#{attr}?".to_sym, attr)
      end
      attr_writer :command_timeout
      def command_timeout
        @command_timeout || 600
      end
    end
  end
end