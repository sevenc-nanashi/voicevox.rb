# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Voicevox::Synthesizer do
  include_context :synthesizer

  it "initializes" do
    synthesizer
  end

  it "returns AudioQuery" do
    query =
      synthesizer.create_audio_query("あ", voice_model.metas[0].styles[0].id)
    expect(query).to be_a Voicevox::AudioQuery
  end

  it "returns Array of AccentPhrase" do
    expect(accent_phrases[0]).to be_a Voicevox::AccentPhrase
  end

  let(:accent_phrases) do
    synthesizer.create_accent_phrases("あ", voice_model.metas[0].styles[0].id)
  end

  [
    ["mora data", :mora_data],
    ["mora pitch", :mora_pitch],
    ["phoneme length", :phoneme_length]
  ].each do |name, method|
    it "changes #{name}" do
      accent_phrases2 =
        synthesizer.send(
          "replace_#{method}",
          accent_phrases,
          voice_model.metas[0].styles[1].id
        )
      expect(accent_phrases2[0]).to be_a Voicevox::AccentPhrase
      expect(accent_phrases).not_to eq accent_phrases2
    end
  end

  it "synthesizes" do
    query =
      synthesizer.create_audio_query("あ", voice_model.metas[0].styles[0].id)
    audio = synthesizer.synthesis(query, voice_model.metas[0].styles[0].id)
    expect(audio).to be_a String
  end

  it "does tts" do
    audio = synthesizer.tts("あ", voice_model.metas[0].styles[0].id)
    expect(audio).to be_a String
  end
end
