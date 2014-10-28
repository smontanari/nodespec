shared_examples 'providing a backend' do |backend_identifier, backend_class|
  it "returns a #{backend_identifier} backend" do
    expect(subject.backend).to eq(backend_identifier)
  end

  it "returns #{backend_class.name} as backend proxy" do
    expect(subject.backend_proxy).to be_a(backend_class)
  end
end

