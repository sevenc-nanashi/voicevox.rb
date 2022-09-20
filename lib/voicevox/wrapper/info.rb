# frozen_string_literal: true

require "json"

class Voicevox
  # サポートされているデバイスを表すStruct。
  SupportedDevices = Struct.new(:cpu, :cuda, :dml, keyword_init: true)

  # キャラクターの情報を表すStruct。
  CharacterInfo =
    Struct.new(:name, :styles, :speaker_uuid, :version, keyword_init: true) do
      #
      # キャラクターの最初のスタイルのIDを返します。
      # @note ほとんどの場合はノーマルになります。
      #
      # @return [Integer] スタイルのID。
      #
      def id
        styles[0].id
      end

      #
      # キャラクターのスタイルが全てロードされているかを返します。
      #
      # @return [Boolean] 全てロードされている場合はtrue、そうでない場合はfalse。
      #
      def loaded?
        styles.map(&:loaded?).all?
      end

      #
      # キャラクターのスタイルを全てロードします。
      #
      # @return [void]
      #
      def load
        Voicevox.initialize_required
        styles.map(&:load)
      end
    end
  StyleInfo =
    Struct.new(:name, :id, keyword_init: true) do
      #
      # スタイルがロードされているかを返します。
      #
      # @return [Boolean] ロードされている場合はtrue、そうでない場合はfalse。
      #
      def loaded?
        Voicevox::Core.is_model_loaded(id)
      end

      #
      # スタイルをロードします。
      #
      # @return [void]
      #
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
        **JSON.parse(Voicevox::Core.voicevox_get_supported_devices_json)
      )
    end

    #
    # キャラクターの一覧を取得します。
    #
    # @return [Array<CharacterInfo>] キャラクターの一覧。
    #
    def characters
      JSON
        .parse(Voicevox::Core.voicevox_get_metas_json)
        .map do |meta|
          CharacterInfo.new(
            **{
              **meta,
              "styles" => meta["styles"].map { |style| StyleInfo.new(**style) }
            }
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
