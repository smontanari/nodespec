require 'nodespec/provisioning'

module NodeSpec
  describe Provisioning do
    let(:subject) {Object.new.extend Provisioning}
    let(:provisioner_instance){double('provisioner instance')}
    provisioners = {
      'puppet' => Provisioning::Puppet,
      'chef' => Provisioning::Chef
    }
    provisioners.each do |name, clazz|
      it "executes the #{clazz} command" do
        block = Proc.new {}
        expect(clazz).to receive(:new).with('foo', 'bar').and_return(provisioner_instance)
        expect(provisioner_instance).to receive(:instance_eval) do |&b|
          expect(b).to be block
        end

        subject.send("node_provision_with_#{name}", 'foo', 'bar', &block)
      end
    end
  end
end