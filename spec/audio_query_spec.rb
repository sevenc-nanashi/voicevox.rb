# frozen_string_literal: true
require_relative "helper"

RSpec.describe("Voicevox") do
  include_context "voicevox_wrapper"

  it "creates AudioQuery" do
    except(vv.audio_query("こんにちは", 0)).to be_a(Voicevox::AudioQuery)
  end

  it "does tts" do
    query = vv.audio_query("こんにちは", 0)
    except(vv.synthesize(query)).to be_a(String)
  end
end
