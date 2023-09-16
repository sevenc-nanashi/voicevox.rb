# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Voicevox::VoiceModel do
  include_context :voice_model
  it "initializes" do
    voice_model
  end

  it "returns id" do
    expect(voice_model.id).to be_a(String)
  end

  it "returns metas" do
    expect(voice_model.metas).to be_a(Array)
    expect(voice_model.metas[0]).to be_a(Voicevox::VoiceModel::Meta)
  end
end
