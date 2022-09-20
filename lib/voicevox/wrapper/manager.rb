# frozen_string_literal: true

require "etc"
require "objspace"

class Voicevox
  @initialized = false
  # @return [:cpu, :gpu] ハードウェアアクセラレーションモード。
  attr_reader :acceleration_mode
  # @return [Integer] スレッド数。
  attr_reader :cpu_num_threads
  # @return [Boolean] 起動時に全てのモデルを読み込むかどうか。
  attr_reader :load_all_models

  #
  # GPUモードで動作しているかどうか。
  #
  # @return [Boolean] GPUモードで動作している場合はtrue、そうでない場合はfalse。
  #
  def gpu?
    @acceleration_mode == :gpu
  end

  #
  # CPUモードで動作しているかどうか。
  #
  # @return [Boolean] CPUモードで動作している場合はtrue、そうでない場合はfalse。
  #
  def cpu?
    @acceleration_mode == :cpu
  end

  #
  # Voicevoxのコアを初期化します。
  #
  # @param [String] openjtalk_dict_path OpenJTalkの辞書へのパス。
  # @param [:cpu, :gpu, :auto] acceleration_mode ハードウェアアクセラレーションモード。:autoを指定するとコア側で自動的に決定されます。
  # @param [Integer] cpu_num_threads スレッド数。省略する、または0を渡すとコア側で自動的に決定されます。
  # @param [Boolean] load_all_models 全てのモデルを読み込むかどうか。省略するとtrueになります。
  #
  def initialize(
    openjtalk_dict_path,
    acceleration_mode: :auto,
    cpu_num_threads: nil,
    load_all_models: false
  )
    acceleration_mode_enum =
      {
        auto: :voicevox_acceleration_mode_auto,
        gpu: :voicevox_acceleration_mode_gpu,
        cpu: :voicevox_acceleration_mode_cpu
      }.fetch(acceleration_mode) do
        raise ArgumentError, "無効なacceleration_mode: #{acceleration_mode}"
      end
    @cpu_num_threads = cpu_num_threads || 0
    @load_all_models = load_all_models
    @openjtalk_dict_path = openjtalk_dict_path
    options = Voicevox::Core::VoicevoxInitializeOptions.new
    options[:acceleration_mode] = acceleration_mode_enum
    options[:cpu_num_threads] = @cpu_num_threads
    options[:load_all_models] = @load_all_models
    options[:openjtalk_dict_path] = FFI::MemoryPointer.from_string(
      openjtalk_dict_path
    )

    Voicevox.process_result Voicevox::Core.voicevox_initialize(options)
    @acceleration_mode = Voicevox::Core.voicevox_is_gpu_mode ? :gpu : :cpu
    self.class.initialized = true
  end

  #
  # Voicevoxのコアをファイナライズします。
  #
  def finalize
    Voicevox::Core.voicevox_finalize
    self.class.initialized = false
  end

  #
  # 話者のモデルを読み込みます。
  #
  # @param [Voicevox::CharacterInfo, Voicevox::StyleInfo, Integer] speaker 話者、または話者のID。
  #
  def load_model(speaker)
    id = speaker.is_a?(Integer) ? speaker : speaker.id

    Voicevox.process_result Voicevox::Core.voicevox_load_model(id)
  end

  #
  # モデルが読み込まれているかどうかを返します。
  #
  # @param [Voicevox::CharacterInfo, Voicevox::StyleInfo, Integer] speaker 話者、または話者のID。
  #
  # @return [Boolean] 読み込まれているかどうか。
  #
  def model_loaded?(speaker)
    id = speaker.is_a?(Integer) ? speaker : speaker.id

    Voicevox::Core.voicevox_is_model_loaded(id)
  end

  #
  # voicevox_ttsを使って音声を生成します。
  #
  # @param [String] text 生成する音声のテキスト。
  # @param [Voicevox::CharacterInfo, Voicevox::StyleInfo, Integer] speaker 話者、または話者のID。
  # @param [Boolean] kana textをAquesTalkライクな記法として解釈するかどうか。デフォルトはfalse。
  # @param [Boolran] enable_interrogative_upspeak 疑問文の調整を有効にするかどうか。デフォルトはtrue。
  #
  # @return [String] 生成された音声のwavデータ。
  #
  def tts(text, speaker, kana: false, enable_interrogative_upspeak: true)
    size_ptr = FFI::MemoryPointer.new(:int)
    return_ptr = FFI::MemoryPointer.new(:pointer)
    id = speaker.is_a?(Integer) ? speaker : speaker.id
    options = Voicevox::Core::VoicevoxTtsOptions.new
    options[:kana] = kana
    options[:enable_interrogative_upspeak] = enable_interrogative_upspeak
    Voicevox.process_result(
      Voicevox::Core.voicevox_tts(text, id, options, size_ptr, return_ptr)
    )
    data_ptr = return_ptr.read_pointer
    size_ptr.free
    data = data_ptr.read_string(size_ptr.read_int)
    Voicevox::Core.voicevox_wav_free(data_ptr)
    data
  end

  class << self
    attr_accessor :initialized

    alias initialized? initialized
  end
end
