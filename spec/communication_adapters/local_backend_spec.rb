require 'spec_helper'
require 'nodespec/communication_adapters/local_backend'

module NodeSpec
  module CommunicationAdapters
    describe LocalBackend do
      let(:subject) {Object.new.extend LocalBackend}

      context 'no os' do
        before do
          def subject.os
          end
        end
        it_behaves_like 'providing a backend', 'Exec'
      end

      context 'UN*X os' do
        before do
          def subject.os
            'CentOS'
          end
        end

        it_behaves_like 'providing a backend', 'Exec'
      end

      context 'Windows os' do
        before do
          def subject.os
            'Windows'
          end
        end

        it_behaves_like 'providing a backend', 'Cmd'
      end
    end
  end
end
