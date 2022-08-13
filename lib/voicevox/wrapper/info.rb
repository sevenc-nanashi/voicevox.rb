require "json"

class Voicevox
  SupportedDevices = Struct.new(:cpu, :cuda, :dml, keyword_init: true)

  #
  # サポートしているデバイスを取得します。
  #
  # @return [Voicevox::SupportedDevices] サポートしているデバイス。
  #
  def self.supported_devices
    SupportedDevices.new(
      **JSON.parse(Voicevox::Core.supported_devices),
    )
  end

  CharacterInfo = Struct.new(:name, :styles, :speaker_uuid, :version, keyword_init: true) do
    def id
      self.styles[0].id
    end

    def loaded?
      self.styles.map(&:loaded?).all?
    end

    def load
      Voicevox.initialize_required
      self.styles.map(&:load)
    end
  end
  StyleInfo = Struct.new(:name, :id, keyword_init: true) do
    def loaded?
      Voicevox::Core.is_model_loaded(self.id)
    end

    def load
      Voicevox.initialize_required
      Voicevox::Core.load_model(self.id) or Voicevox.failed
    end
  end

  #
  # キャラクターの一覧を取得します。
  #
  # @return [Array<CharacterInfo>] キャラクターの一覧。
  #
  def self.characters
    JSON.parse(Voicevox::Core.metas).map do |meta|
      CharacterInfo.new(
        **{
          **meta,
          "styles" => meta["styles"].map { |style| StyleInfo.new(**style) },
        },
      )
    end
  end
end
