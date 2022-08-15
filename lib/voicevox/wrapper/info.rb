# frozen_string_literal: true

require "json"

class Voicevox
  SupportedDevices = Struct.new(:cpu, :cuda, :dml, keyword_init: true)

  CharacterInfo = Struct.new(:name, :styles, :speaker_uuid, :version, keyword_init: true) do
    def id
      styles[0].id
    end

    def loaded?
      styles.map(&:loaded?).all?
    end

    def load
      Voicevox.initialize_required
      styles.map(&:load)
    end
  end
  StyleInfo = Struct.new(:name, :id, keyword_init: true) do
    def loaded?
      Voicevox::Core.is_model_loaded(id)
    end

    def load
      Voicevox.initialize_required
      Voicevox::Core.load_model(id) || Voicevox.failed
    end
  end

  class << self
    #
    # サポートしているデバイスを取得します。
    #
    # @return [Voicevox::SupportedDevices] サポートしているデバイス。
    #
    def supported_devices
      SupportedDevices.new(
        **JSON.parse(Voicevox::Core.supported_devices),
      )
    end

    #
    # キャラクターの一覧を取得します。
    #
    # @return [Array<CharacterInfo>] キャラクターの一覧。
    #
    def characters
      JSON.parse(Voicevox::Core.metas).map do |meta|
        CharacterInfo.new(
          **{
            **meta,
            "styles" => meta["styles"].map { |style| StyleInfo.new(**style) },
          },
        )
      end
    end

    #
    # GPUをサポートしているかを返します。
    #
    # @note CUDA、またはDirectMLが使える場合にtrueを返します。
    #
    # @return [Boolean] GPUをサポートしているかどうか。
    #
    def gpu_supported?
      Voicevox.supported_devices.cuda || Voicevox.supported_devices.dml
    end
  end
end
