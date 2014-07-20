shared_examples 'providing a backend' do |expected_backend|
  it "returns #{expected_backend} backend" do
    expect(subject.backend).to eq(expected_backend)
  end

  it "returns BackendProxy::#{expected_backend} as backend proxy" do
    expect(subject.backend_proxy).to be_a(NodeSpec::BackendProxy.const_get(expected_backend))
  end
end

