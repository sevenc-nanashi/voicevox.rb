# frozen_string_literal: true
require_relative "helper"

RSpec.describe("Voicevox::AudioQuery") do
  include_context "voicevox_wrapper"

  it "creates AudioQuery" do
    expect(vv.audio_query("こんにちは", 0)).to be_a(Voicevox::AudioQuery)
  end

  it "does tts" do
    query = vv.audio_query("こんにちは", 0)
    expect(vv.synthesis(query, 0)).to be_a(String)
  end
end
