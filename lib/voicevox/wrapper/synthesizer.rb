# frozen_string_literal: true

module Voicevox
  #
  # 音声シンセサイザ。
  #
  class Synthesizer
    #
    # 音声シンセサイザを構築する。
    #
    # @param [OpenJtalk] open_jtalk {OpenJtalk}のインスタンス。
    # @param [:auto, :cpu, :gpu] acceleration_mode ハードウェアアクセラレーションモード。
    # @param [Integer] cpu_num_threads CPU利用数。
    #   nilを指定すると環境に合わせたCPUが利用される。
    # @param [Boolean] load_all_models 全てのモデルを読み込むかどうか。
    #
    def initialize(
      open_jtalk,
      acceleration_mode: :cpu,
      cpu_num_threads: nil,
      load_all_models: false
    )
      options = Core.voicevox_make_default_initialize_options
      options[:acceleration_mode] = case acceleration_mode
      when :auto
        :voicevox_acceleration_mode_auto
      when :cpu
        :voicevox_acceleration_mode_cpu
      when :gpu
        :voicevox_acceleration_mode_gpu
      else
        raise ArgumentError, "invalid acceleration_mode: #{acceleration_mode}"
      end
      options[:cpu_num_threads] = cpu_num_threads || 0
      options[:load_all_models] = load_all_models

      pointer = FFI::MemoryPointer.new(Core::Uintptr)

      Voicevox.process_result Core.voicevox_synthesizer_new_with_initialize(
                                open_jtalk.pointer,
                                options,
                                pointer
                              )

      @pointer =
        FFI::AutoPointer.new(
          pointer.read_pointer,
          Core.method(:voicevox_synthesizer_delete)
        )
    end

    #
    # 音声モデルを読み込む。
    #
    # @param [VoiceModel] model 音声モデル。
    #
    def load_voice_model(model)
      Voicevox.process_result Core.voicevox_synthesizer_load_voice_model(
                                @pointer,
                                model.pointer
                              )
    end

    #
    # 音声モデルの読み込みを解除する。
    #
    # @param [String] id 音声モデルID。
    #
    def unload_voice_model(id)
      Voicevox.process_result Core.voicevox_synthesizer_unload_voice_model(
                                @pointer,
                                id
                              )
    end

    #
    # 指定したIDの音声モデルが読み込まれているか判定する。
    #
    # @param [String] id 音声モデルID。
    # @return [Boolean] 音声モデルが読み込まれているかどうか。
    #
    def loaded_voice_model?(id)
      Core.voicevox_synthesizer_is_loaded(@pointer, id)
    end

    #
    # ハードウェアアクセラレーションがGPUモードか判定する。
    #
    # @return [Boolean] GPUモードかどうか。
    #
    def gpu_mode?
      Core.voicevox_synthesizer_is_gpu_mode(@pointer)
    end

    #
    # 今読み込んでいる音声も出るのメタ情報を取得する。
    #
    # @return [Array<Meta>] メタ情報。
    #
    def metas
      Core
        .voicevox_synthesizer_get_metas_json(@pointer)
        .then do |json|
          parsed = JSON.parse(json, symbolize_names: true)
          parsed.map do |meta|
            Meta.new(
              meta[:name],
              meta[:speaker_uuid],
              meta[:styles].map { |style| Style.new(style[:name], style[:id]) },
              meta[:version]
            )
          end
        end
    end

    #
    # {AudioQuery}を生成する。
    #
    # @param [String] text テキスト。
    # @param [String] style_id スタイルID。
    # @param [Boolean] kana AquesTalk風記法としてテキストを解釈するかどうか。
    #
    # @return [AudioQuery] 生成した{AudioQuery}。
    #
    def create_audio_query(text, style_id, kana: false)
      pointer = FFI::MemoryPointer.new(Core::Uintptr)

      options = Core.voicevox_make_default_audio_query_options

      options[:kana] = kana

      Voicevox.process_result Core.voicevox_synthesizer_create_audio_query(
                                @pointer,
                                text,
                                style_id,
                                options,
                                pointer
                              )
      json = JSON.parse(pointer.read_pointer.read_string, symbolize_names: true)

      Core.voicevox_json_free(pointer.read_pointer)

      AudioQuery.new(json)
    end

    #
    # {AccentPhrase AccentPhrase（アクセント句）}の配列を生成する。
    #
    # @param [String] text テキスト。
    # @param [String] style_id スタイルID。
    # @param [Boolean] kana AquesTalk風記法としてテキストを解釈するかどうか。
    #
    # @return [AudioQuery] 生成した{AudioQuery}。
    #
    def create_accent_phrases(text, style_id, kana: false)
      pointer = FFI::MemoryPointer.new(Core::Uintptr)

      options = Core.voicevox_make_default_audio_query_options

      options[:kana] = kana

      Voicevox.process_result Core.voicevox_synthesizer_create_accent_phrases(
                                @pointer,
                                text,
                                style_id,
                                options,
                                pointer
                              )
      json = JSON.parse(pointer.read_pointer.read_string, symbolize_names: true)

      Core.voicevox_json_free(pointer.read_pointer)

      json.map { |accent_phrase| AccentPhrase.new(accent_phrase) }
    end

    #
    # AccentPhraseの配列の音高・音素長を、特定の声で生成しなおす。
    #
    # @param [Array<AccentPhrase>] accent_phrases AccentPhraseの配列。
    # @param [String] style_id スタイルID。
    #
    # @return [Array<AccentPhrase>] 生成したAccentPhraseの配列。
    #
    def replace_mora_data(accent_phrases, style_id)
      pointer = FFI::MemoryPointer.new(Core::Uintptr)

      Voicevox.process_result Core.voicevox_synthesizer_replace_mora_data(
                                @pointer,
                                accent_phrases.to_json,
                                style_id,
                                pointer
                              )
      json = JSON.parse(pointer.read_pointer.read_string, symbolize_names: true)

      Core.voicevox_json_free(pointer.read_pointer)

      json.map { |accent_phrase| AccentPhrase.new(accent_phrase) }
    end

    #
    # AccentPhraseの配列の音素長を、特定の声で生成しなおす。
    #
    # @param [Array<AccentPhrase>] accent_phrases AccentPhraseの配列。
    # @param [String] style_id スタイルID。
    #
    # @return [Array<AccentPhrase>] 生成したAccentPhraseの配列。
    #
    def replace_phoneme_length(accent_phrases, style_id)
      pointer = FFI::MemoryPointer.new(Core::Uintptr)

      Voicevox.process_result Core.voicevox_synthesizer_replace_phoneme_length(
                                @pointer,
                                accent_phrases.to_json,
                                style_id,
                                pointer
                              )
      json = JSON.parse(pointer.read_pointer.read_string, symbolize_names: true)

      Core.voicevox_json_free(pointer.read_pointer)

      json.map { |accent_phrase| AccentPhrase.new(accent_phrase) }
    end

    #
    # AccentPhraseの配列の音高を、特定の声で生成しなおす。
    #
    # @param [Array<AccentPhrase>] accent_phrases AccentPhraseの配列。
    # @param [String] style_id スタイルID。
    #
    # @return [Array<AccentPhrase>] 生成したAccentPhraseの配列。
    #
    def replace_mora_pitch(accent_phrases, style_id)
      pointer = FFI::MemoryPointer.new(Core::Uintptr)

      Voicevox.process_result Core.voicevox_synthesizer_replace_mora_pitch(
                                @pointer,
                                accent_phrases.to_json,
                                style_id,
                                pointer
                              )

      json = JSON.parse(pointer.read_pointer.read_string, symbolize_names: true)

      Core.voicevox_json_free(pointer.read_pointer)

      json.map { |accent_phrase| AccentPhrase.new(accent_phrase) }
    end

    #
    # {AudioQuery}から音声合成を行う。
    #
    # @param [AudioQuery] audio_query {AudioQuery}。
    # @param [String] style_id スタイルID。
    # @param [Boolean] interrogative_upspeak 疑問文の調整を有効にするかどうか。
    #
    # @return [String] WAVデータ。
    #
    def synthesis(audio_query, style_id, interrogative_upspeak: false)
      length_pointer = FFI::MemoryPointer.new(Core::Uintptr)
      data_pointer = FFI::MemoryPointer.new(Core::Uintptr)

      options = Core.voicevox_make_default_synthesis_options

      options[:enable_interrogative_upspeak] = interrogative_upspeak

      Voicevox.process_result Core.voicevox_synthesizer_synthesis(
                                @pointer,
                                audio_query.to_json,
                                style_id,
                                options,
                                length_pointer,
                                data_pointer
                              )

      wav =
        data_pointer.read_pointer.read_bytes(length_pointer.read(Core::Uintptr))

      Core.voicevox_wav_free(data_pointer.read_pointer)

      wav
    end

    #
    # テキスト音声合成を行う。
    #
    # @param [String] text テキスト。
    # @param [String] style_id スタイルID。
    # @param [Boolean] kana AquesTalk風記法としてテキストを解釈するかどうか。
    # @param [Boolean] interrogative_upspeak 疑問文の調整を有効にするかどうか。
    #
    # @return [String] WAVデータ。
    #
    def tts(text, style_id, kana: false, interrogative_upspeak: false)
      length_pointer = FFI::MemoryPointer.new(Core::Uintptr)
      data_pointer = FFI::MemoryPointer.new(Core::Uintptr)

      options = Core.voicevox_make_default_tts_options

      options[:kana] = kana
      options[:enable_interrogative_upspeak] = interrogative_upspeak

      Voicevox.process_result Core.voicevox_synthesizer_tts(
                                @pointer,
                                text,
                                style_id,
                                options,
                                length_pointer,
                                data_pointer
                              )

      wav =
        data_pointer.read_pointer.read_bytes(length_pointer.read(Core::Uintptr))

      Core.voicevox_wav_free(data_pointer.read_pointer)

      wav
    end
  end
end
