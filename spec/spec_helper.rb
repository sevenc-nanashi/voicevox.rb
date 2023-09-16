# frozen_string_literal: true

require "voicevox"

def open_jtalk_dic_dir
  @open_jtalk_dic_dir =
    ENV.fetch("VOICEVOX_OPEN_JTALK_DIC_DIR") do
      raise "VOICEVOX_OPEN_JTALK_DIC_DIR is not set"
    end
end

def voice_model_path
  @voice_model_path =
    ENV.fetch("VOICEVOX_VOICE_MODEL_PATH") do
      raise "VOICEVOX_VOICE_MODEL_PATH is not set"
    end
end

shared_context :voice_model do
  let :voice_model do
    Voicevox::VoiceModel.new(voice_model_path)
  end
end

shared_context :user_dict do
  let :user_dict do
    Voicevox::UserDict.new
  end
end

shared_context :open_jtalk do
  let :open_jtalk do
    Voicevox::OpenJtalk.new(open_jtalk_dic_dir)
  end
end

shared_context :synthesizer do
  include_context :voice_model
  include_context :open_jtalk

  let :synthesizer do
    synthesizer = Voicevox::Synthesizer.new(open_jtalk)
    synthesizer.load_voice_model(voice_model)
    synthesizer
  end
end
