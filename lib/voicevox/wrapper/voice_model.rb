# frozen_string_literal: true

module Voicevox
  # 音声モデル。
  #
  # VVMファイルと対応する。
  class VoiceModel
    # @private
    attr_reader :pointer

    #
    # VVMファイルから{VoiceModel}を構築する。
    #
    # @param [String] path VVMファイルのパス。
    #
    def initialize(path)
      pointer = FFI::MemoryPointer.new(Core::Uintptr)

      Voicevox.process_result Core.voicevox_voice_model_new_from_path(
                                path,
                                pointer
                              )

      @pointer =
        FFI::AutoPointer.new(
          pointer.read_pointer,
          Core.method(:voicevox_voice_model_delete)
        )
    end

    #
    # IDを取得する。
    #
    # @return [String] ID。
    #
    def id
      @id ||= Core.voicevox_voice_model_id(@pointer)
    end

    #
    # メタ情報を取得する。
    #
    # @return [Metas] メタ情報。
    #
    def metas
      @metas ||=
        Core
          .voicevox_voice_model_get_metas_json(@pointer)
          .then do |json|
            parsed = JSON.parse(json, symbolize_names: true)
            parsed.map do |meta|
              Meta.new(
                meta[:name],
                meta[:speaker_uuid],
                meta[:styles].map do |style|
                  Style.new(style[:name], style[:id])
                end,
                meta[:version]
              )
            end
          end
    end

    def to_s
      @path
    end

    #
    # 音声モデルのメタ情報。
    #
    # @!attribute [r] name
    #   @return [String] 名前。
    # @!attribute [r] speaker_uuid
    #   @return [String] スピーカーのUUID。
    # @!attribute [r] styles
    #   @return [Array<Style>] スピーカースタイルの配列。
    # @!attribute [r] version
    #   @return [String] スピーカーのバージョン。
    #
    Meta = Struct.new(:name, :speaker_uuid, :styles, :version)

    #
    # 音声モデルのスタイル。
    #
    # @!attribute [r] name
    #   @return [String] スタイル名。
    # @!attribute [r] id
    #   @return [String] スタイルID。
    #
    Style = Struct.new(:name, :id)
  end
end
