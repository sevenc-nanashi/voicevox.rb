# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Voicevox::UserDict do
  let :dict do
    Voicevox::UserDict.new
  end
  include_context :voice_model

  let :word1 do
    Voicevox::UserDict::Word.new("あ", "ア")
  end
  let :word2 do
    Voicevox::UserDict::Word.new("い", "イ")
  end

  it "initializes" do
    dict
  end

  it "adds word" do
    expect(uuid = dict.add_word(word1)).to be_a String

    expect(dict[uuid].surface).to eq("あ")
  end

  it "updates word" do
    uuid = dict.add_word(word1)
    dict.update_word(uuid, word2)

    expect(dict[uuid].surface).to eq("い")
  end

  it "removes word" do
    uuid = dict.add_word(word1)
    dict.remove_word(uuid)

    expect(dict[uuid]).to be_nil
  end

  it "changes kana" do
    open_jtalk = Voicevox::OpenJtalk.new(open_jtalk_dic_dir)
    synthesizer = Voicevox::Synthesizer.new(open_jtalk)
    synthesizer.load_voice_model(voice_model)
    query1 =
      synthesizer.create_audio_query(
        "random_word",
        voice_model.metas[0].styles[0].id
      )
    dict.add_word(Voicevox::UserDict::Word.new("random_word", "アイウエ"))
    open_jtalk.user_dict = dict
    query2 =
      synthesizer.create_audio_query(
        "random_word",
        voice_model.metas[0].styles[0].id
      )

    expect(query1.kana).not_to eq(query2.kana)
  end
end
