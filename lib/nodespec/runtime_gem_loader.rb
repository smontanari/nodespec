module NodeSpec
  module RuntimeGemLoader
    DEFAULT_ERROR_MSG = 'Consider installing the missing gem'
    def self.require_or_fail(gem_name, error_message = nil)
      begin
        require gem_name
          yield if block_given?
      rescue LoadError => e
        err = <<-EOS
Error: #{e.message}
#{error_message || DEFAULT_ERROR_MSG}

gem install '#{gem_name}'
EOS
        fail(err)
        end
      end
  end
end