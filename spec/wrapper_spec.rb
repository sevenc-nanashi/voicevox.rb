# frozen_string_literal: true
require_relative "helper"

RSpec.describe("Voicevox") do
  include_context "voicevox_wrapper"

  it "does tts" do
    expect { vv.tts("こんにちは。", 1) }.not_to raise_error
  end

  it "returns core version" do
    expect(Voicevox.core_version).to be_a(String)
  end

  it "returns library version" do
    expect(Voicevox::VERSION).to be_a(String)
  end
end

