require 'spec_helper'
require 'nodespec/communication_adapters/remote_backend'

module NodeSpec
  module CommunicationAdapters
    describe RemoteBackend do
      let(:subject) {
        Object.new.tap do |obj|
          obj.extend RemoteBackend
          def obj.session
            'session'
          end
        end
      }

      context 'no os' do
        before do
          def subject.os
          end
        end

        it_behaves_like 'providing a backend', 'Ssh'
      end

      context 'UN*X os' do
        before do
          def subject.os
            'CentOS'
          end
        end

        it_behaves_like 'providing a backend', 'Ssh'
      end

      context 'Windows os' do
        before do
          def subject.os
            'Windows'
          end
        end

        it_behaves_like 'providing a backend', 'WinRM'
      end
    end
  end
end
