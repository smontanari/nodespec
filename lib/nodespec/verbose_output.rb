require_relative 'run_options'

module NodeSpec
  module VerboseOutput
    def verbose_puts(msg)
      puts msg if NodeSpec::RunOptions.verbose?
    end
  end
end