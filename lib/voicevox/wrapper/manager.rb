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

  class << self
    attr_accessor :initialized
  end

  private

  def self.initialize_required
    raise Voicevox::Error, "Voicevoxが初期化されていません" unless initialized?
  end
end
