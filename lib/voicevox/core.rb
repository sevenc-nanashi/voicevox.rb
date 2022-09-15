# frozen_string_literal: true

require "ffi"
require "English"

class Voicevox
  #
  # voicevox_coreの薄いラッパー。
  #
  module Core
    extend FFI::Library
    ffi_lib %w[core.dll libcore.dylib libcore.so]

    enum :voicevox_result_code,
         {
           voicevox_result_succeed: 0,
           voicevox_result_not_loaded_openjtalk_dict: 1,
           voicevox_result_failed_load_model: 2,
           voicevox_result_failed_get_supported_devices: 3,
           voicevox_result_cant_gpu_support: 4,
           voicevox_result_failed_load_metas: 5,
           voicevox_result_uninitialized_status: 6,
           voicevox_result_invalid_speaker_id: 7,
           voicevox_result_invalid_model_index: 8,
           voicevox_result_inference_failed: 9,
           voicevox_result_failed_extract_full_context_label: 10,
           voicevox_result_invalid_utf8_input: 11,
           voicevox_result_failed_parse_kana: 12,
           voicevox_result_invalid_audio_query: 13
         }.to_a.flatten

    enum :voicevox_acceleration_mode,
         {
           voicevox_acceleration_mode_auto: 0,
           voicevox_acceleration_mode_cpu: 1,
           voicevox_acceleration_mode_gpu: 2
         }.to_a.flatten

    class VoicevoxInitializeOptions < FFI::Struct
      layout(
        *{
          acceleration_mode: :voicevox_acceleration_mode,
          cpu_num_threads: :int16,
          load_all_models: :bool,
          openjtalk_dict_path: :pointer
        }.to_a.flatten
      )
    end

    class VoicevoxAudioQueryOptions < FFI::Struct
      layout :kana, :bool
    end

    class VoicevoxSynthesisOptions < FFI::Struct
      layout :enable_interrogative_upspeak, :bool
    end

    class VoicevoxTtsOptions < FFI::Struct
      layout :kana, :bool, :enable_interrogative_upspeak, :bool
    end

    attach_function :voicevox_make_default_initialize_options,
                    [],
                    VoicevoxInitializeOptions.by_value

    attach_function :voicevox_initialize,
                    [VoicevoxInitializeOptions.by_value],
                    :voicevox_result_code

    attach_function :voicevox_load_model, [:int64], :voicevox_result_code

    attach_function :voicevox_is_gpu_mode, [], :bool

    attach_function :voicevox_is_model_loaded, [:int64], :bool

    attach_function :voicevox_finalize, [], :void

    attach_function :voicevox_get_metas_json, [], :string

    attach_function :voicevox_get_supported_devices_json, [], :string

    attach_function :voicevox_predict_duration,
                    %i[int64 pointer int32 pointer],
                    :voicevox_result_code

    attach_function :voicevox_predict_intonation,
                    %i[
                      int64
                      pointer
                      pointer
                      pointer
                      pointer
                      pointer
                      pointer
                      int32
                      pointer
                    ],
                    :voicevox_result_code

    attach_function :voicevox_decode,
                    %i[int64 int64 pointer pointer int32 pointer],
                    :voicevox_result_code

    attach_function :voicevox_make_default_audio_query_options,
                    [],
                    VoicevoxAudioQueryOptions.by_value

    attach_function :voicevox_audio_query,
                    [
                      :string,
                      :int32,
                      VoicevoxAudioQueryOptions.by_value,
                      :pointer
                    ],
                    :voicevox_result_code

    attach_function :voicevox_synthesis,
                    [
                      :string,
                      :int32,
                      VoicevoxSynthesisOptions.by_value,
                      :pointer,
                      :pointer
                    ],
                    :voicevox_result_code

    attach_function :voicevox_make_default_tts_options,
                    [],
                    VoicevoxTtsOptions.by_value

    attach_function :voicevox_tts,
                    [
                      :string,
                      :int64,
                      VoicevoxTtsOptions.by_value,
                      :pointer,
                      :pointer
                    ],
                    :voicevox_result_code

    attach_function :voicevox_audio_query_json_free, [:pointer], :void
    attach_function :voicevox_wav_free, [:pointer], :void

    attach_function :voicevox_error_result_to_message,
                    [:voicevox_result_code],
                    :string
  rescue FFI::NotFoundError
    raise LoadError,
          "関数をロードできませんでした。古いバージョンのcore.dllを使っている可能性があります。",
          cause: $ERROR_INFO
  end
end
