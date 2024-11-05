# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AdequateJson::Railtie do
  it 'includes AdequateJson::Serializer in ActionController::API' do
    expect(ActionController::API.included_modules).to include(AdequateJson::Serializer)
  end
end
