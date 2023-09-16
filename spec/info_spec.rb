# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Voicevox do
  it "returns version" do
    expect(Voicevox.core_version).to be_a(String)
  end

  specify "Voicevox.supported_devices.cpu is always true" do
    expect(Voicevox.supported_devices.cpu).to be true
  end
end
