# frozen_string_literal: true

RSpec.describe AdequateJson do
  it 'has a version number' do
    expect(AdequateJson::VERSION).not_to be nil
  end

  it 'yields a configuration' do
    expect { |b| described_class.configure(&b) }.to yield_with_args(AdequateJson::ConfigurationBuilder)
  end
end
