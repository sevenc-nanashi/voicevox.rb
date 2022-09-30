# frozen_string_literal: true
require "voicevox"

RSpec.shared_context "voicevox_wrapper" do
  # @type lvar vv: Voicevox
  let(:vv) do
    vv =
      Voicevox.new(
        ENV.fetch("VOICEVOX_OPEN_JTALK_DICT") do
          raise "Set environment variable VOICEVOX_OPEN_JTALK_DICT"
        end,
        acceleration_mode: :cpu,
        load_all_models: false
      )
    vv.load_model 1
    vv
  end

  after { vv.finalize }
end
