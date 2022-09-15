# frozen_string_literal: true
require_relative "helper"

RSpec.describe("Voicevox") do
  include_context "voicevox_wrapper"

  it "does tts" do
    vv.tts("こんにちは。", 1)
  end
end