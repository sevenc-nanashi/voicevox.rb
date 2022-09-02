# frozen_string_literal: true

Rspec.shared_context "voicevox_wrapper" do
  # @type lvar vv: Voicevox
  let(:vv) do
    Voicevox.new
  end

  before do
    vv.init(load_all_models: false)
    vv.load_model 1
  end
end
