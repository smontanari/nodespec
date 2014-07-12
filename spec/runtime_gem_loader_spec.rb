require 'nodespec/runtime_gem_loader'

module NodeSpec
  describe RuntimeGemLoader do
    it 'requires the gem successfully and executes the block' do
      success = false
      RuntimeGemLoader.require_or_fail('rspec') do
        success = true
      end
      expect(success).to be_truthy
    end

    it 'fails to require the gem and prints a default error message' do
      success = false
      expect do
        RuntimeGemLoader.require_or_fail('a-gem-that/does-not-exist') do
          success = true
        end
      end.to raise_error(/Consider installing the missing gem\s+gem install 'a-gem-that\/does-not-exist'/)
      expect(success).to be_falsy
    end

    it 'fails to require the gem and prints a custom error message' do
      success = false
      expect do
        RuntimeGemLoader.require_or_fail('a-gem-that/does-not-exist', 'this is wrong') do
          success = true
        end
      end.to raise_error(/this is wrong\s+gem install 'a-gem-that\/does-not-exist'/)
      expect(success).to be_falsy
    end
  end
end