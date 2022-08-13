require "etc"

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
  # @param [Boolean] load_model モデルを読み込むかどうか。省略するとtrueになります。
  #
  def init(use_gpu: :auto, threads: nil, load_model: true)
    @use_gpu = use_gpu == :auto ? Voicevox.supported_devices.cuda || Voicevox.supported_devices.dml : use_gpu
    @threads = threads || Etc.nprocessors
    @load_model = load_model
    Voicevox::Core.initialize(@use_gpu, @threads, @load_model) or Voicevox.failed
    self.class.initialized = true
  end

  class << self
    attr_accessor :initialized
  end

  private

  def require_initialize
    raise Voicevox::Error, "Voicevoxが初期化されていません" unless initialized?
  end
end
