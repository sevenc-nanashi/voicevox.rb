require "etc"
require "objspace"

class Voicevox
  @initialized = false

  #
  # Voicevoxクラスのインスタンスを初期化します。
  #
  def initialize
  end

  #
  # Voicevoxのコアが初期化されているか。
  #
  # @return [Boolean] 初期化されている場合はtrue、そうでない場合はfalse。
  #
  def initialized?
    self.class.initialized
  end

  #
  # Voicevoxのコアを初期化します。
  #
  # @param [Boolean, :auto] use_gpu GPUを使うかどうか。:autoを指定するとDirectML、またはCUDAが使える場合にtrueになります。
  # @param [Integer] threads スレッド数。省略するとEtc.nprocessorsの値になります。
  # @param [Boolean] load_all_models 全てのモデルを読み込むかどうか。省略するとtrueになります。
  #
  def init(use_gpu: :auto, threads: nil, load_all_models: true)
    @use_gpu = use_gpu == :auto ? Voicevox.supported_devices.cuda || Voicevox.supported_devices.dml : use_gpu
    @threads = threads || Etc.nprocessors
    @load_all_models = load_all_models
    Voicevox::Core.initialize(@use_gpu, @threads, @load_all_models) or Voicevox.failed unless initialized?
    self.class.initialized = true
  end

  #
  # Voicevoxのコアをファイナライズします。
  #
  def finalize
    Voicevox::Core.finalize or Voicevox.failed
    self.class.initialized = false
  end

  #
  # OpenJTalkの辞書を読み込みます。
  #
  # @param [String] path 辞書へのパス。
  #
  def load_openjtalk_dict(path)
    Voicevox::Core.voicevox_load_openjtalk_dict(path) or Voicevox.failed
  end

  #
  # voicevox_ttsを使って音声を生成します。
  #
  # @param [String] text 生成する音声のテキスト。
  # @param [Voicevox::CharacterInfo, Voicevox::CharacterInfo, Integer] speaker 話者、または話者のID。
  #
  # @return [String] 生成された音声のwavデータ。
  #
  def tts(text, speaker)
    size_ptr = FFI::MemoryPointer.new(:int)
    return_ptr = FFI::MemoryPointer.new(:pointer)
    id = speaker.is_a?(Integer) ? speaker : speaker.id
    Voicevox.process_result Voicevox::Core.voicevox_tts(text, id, size_ptr, return_ptr)
    data_ptr = return_ptr.read_pointer
    data_ptr.read_string(size_ptr.read_int)
  end

  class << self
    attr_accessor :initialized
  end
end
