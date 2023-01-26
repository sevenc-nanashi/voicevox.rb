# frozen_string_literal: true

require "ffi"
require "English"

class Voicevox
  #
  # voicevox_coreの薄いラッパー。
  #
  module Core
    extend FFI::Library

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
    ffi_lib %w[voicevox_core.dll libvoicevox_core.dylib libvoicevox_core.so]

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

    # attach_function :voicevox_make_default_synthesis_options,
    #                 [],
    #                 VoicevoxSynthesisOptions.by_value

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
  rescue LoadError
    $e1 = $ERROR_INFO
    module Old
      extend FFI::Library
      ffi_lib %w[core.dll libcore.dylib libcore.so]

      enum :voicevox_result_code,
           [
             :voicevox_result_succeed,
             0,
             :voicevox_result_not_loaded_openjtalk_dict,
             1,
             :voicevox_result_failed_load_model,
             2,
             :voicevox_result_failed_get_supported_devices,
             3,
             :voicevox_result_cant_gpu_support,
             4,
             :voicevox_result_failed_load_metas,
             5,
             :voicevox_result_uninitialized_status,
             6,
             :voicevox_result_invalid_speaker_id,
             7,
             :voicevox_result_invalid_model_index,
             8,
             :voicevox_result_inference_failed,
             9,
             :voicevox_result_failed_extract_full_context_label,
             10,
             :voicevox_result_invalid_utf8_input,
             11,
             :voicevox_result_failed_parse_kana,
             12
           ]

      attach_function :initialize, %i[bool int bool], :bool

      attach_function :load_model, [:int64], :bool

      attach_function :is_model_loaded, [:int64], :bool

      attach_function :finalize, [], :void

      attach_function :metas, [], :string

      attach_function :last_error_message, [], :string

      attach_function :supported_devices, [], :string

      attach_function :yukarin_s_forward,
                      %i[int64 pointer pointer pointer],
                      :bool

      attach_function :yukarin_sa_forward,
                      %i[
                        int64
                        pointer
                        pointer
                        pointer
                        pointer
                        pointer
                        pointer
                        pointer
                        pointer
                      ],
                      :bool

      attach_function :decode_forward,
                      %i[int64 int64 pointer pointer pointer pointer],
                      :bool

      attach_function :voicevox_load_openjtalk_dict,
                      [:string],
                      :voicevox_result_code

      attach_function :voicevox_tts,
                      %i[string int64 pointer pointer],
                      :voicevox_result_code

      attach_function :voicevox_tts_from_kana,
                      %i[string int64 pointer pointer],
                      :voicevox_result_code

      attach_function :voicevox_wav_free, [:pointer], :void

      attach_function :voicevox_error_result_to_message,
                      [:voicevox_result_code],
                      :string
    rescue LoadError => e2
      raise(
        LoadError,
        "Failed to load voicevox_core! " +
          "(voicevox_core.dll, libvoicevox_core.so, libvoicevox_core.dylib, " +
          "core.dll, libcore.so, libcore.dylib)\n" +
          "Make sure you have installed voicevox_core and its dependencies " +
          "(such as onnxruntime), and that the voicevox_core shared library " +
          "can be found in your library path."
      )
    end

    module_function

    # @return [Voicevox::Core::VoicevoxInitializeOptions]
    def voicevox_make_default_initialize_options
      options = VoicevoxInitializeOptions.new
      options[:acceleration_mode] = :voicevox_acceleration_mode_auto
      options[:cpu_num_threads] = 0
      options[:load_all_models] = false
      options[:openjtalk_dict_path] = nil
      options
    end

    # @param [Voicevox::Core::VoicevoxInitializeOptions]
    # @return [Symbol]
    def voicevox_initialize(options)
      gpu =
        case options[:acceleration_mode]
        when :voicevox_acceleration_mode_auto
          supported_devices = JSON.parse(Old.supported_devices)
          supported_devices["cuda"] || supported_devices["dml"]
        when :voicevox_acceleration_mode_gpu
          true
        when :voicevox_acceleration_mode_cpu
          false
        end
      @is_gpu_mode = gpu
      if Old.initialize(
           gpu,
           options[:cpu_num_threads],
           options[:load_all_models]
         )
        Old.voicevox_load_openjtalk_dict(
          options[:openjtalk_dict_path].read_string
        )
      else
        raise(Old.last_error_message)
      end
    end

    # @param [Integer] speaker_id
    # @return [Symbol]
    def voicevox_load_model(speaker_id)
      if Old.load_model(speaker_id)
        :voicevox_result_succeed
      else
        raise(Old.last_error_message)
      end
    end

    # @param [Integer] speaker_id
    # @return [Boolean]
    def voicevox_is_model_loaded(speaker_id)
      Old.is_model_loaded(speaker_id)
    end

    # @return [Boolean]
    def voicevox_is_gpu_mode
      @is_gpu_mode
    end

    # @return [void]
    def voicevox_finalize
      Old.finalize
    end

    # @return [String]
    def voicevox_get_metas_json
      Old.metas
    end

    # @return [String]
    def voicevox_get_supported_devices_json
      Old.supported_devices
    end

    # @param [Ingeger] length
    # @param [FFI::Pointer<Integer>] phoneme_list
    # @param [Integer] speaker_id
    # @param [FFI::Pointer<Integer>] output
    # @return [Symbol]
    def voicevox_predict_duration(length, phoneme_list, speaker_id, output)
      speaker_id_ptr = FFI::MemoryPointer.new(:int64)
      speaker_id_ptr.put(:int64, 0, speaker_id)
      if Old.yukarin_s_forward(length, phoneme_list, speaker_id_ptr, output)
        :voicevox_result_succeed
      else
        raise(Old.last_error_message)
      end
    end

    # @param [Ingeger] length
    # @param [FFI::Pointer<Integer>] phoneme_list
    # @param [FFI::Pointer<Integer>] vowel_phoneme_list
    # @param [FFI::Pointer<Integer>] consonant_phoneme_list
    # @param [FFI::Pointer<Integer>] start_accent_list
    # @param [FFI::Pointer<Integer>] end_accent_list
    # @param [FFI::Pointer<Integer>] start_accent_phrase_list
    # @param [FFI::Pointer<Integer>] end_accent_phrase_list
    # @param [Integer] speaker_id
    # @param [FFI::Pointer<Integer>] output
    # @return [Symbol]
    def voicevox_predict_intonation(
      length,
      vowel_phoneme_list,
      consonant_phoneme_list,
      start_accent_list,
      end_accent_list,
      start_accent_phrase_list,
      end_accent_phrase_list,
      speaker_id,
      output
    )
      speaker_id_ptr = FFI::MemoryPointer.new(:int64)
      speaker_id_ptr.put(:int64, 0, speaker_id)
      if Old.yukarin_sa_forward(
           length,
           vowel_phoneme_list,
           consonant_phoneme_list,
           start_accent_list,
           end_accent_list,
           start_accent_phrase_list,
           end_accent_phrase_list,
           speaker_id_ptr,
           output
         )
        :voicevox_result_succeed
      else
        raise(Old.last_error_message)
      end
    end

    # @param [Ingeger] length
    # @param [Integer] phoneme_size
    # @param [FFI::Pointer<Float>] f0
    # @param [FFI::Pointer<Float>] phoneme
    # @param [Integer] speaker_id
    # @param [FFI::Pointer<Integer>] output
    # @return [Symbol]
    def voicevox_decode(length, phoneme_size, f0, phoneme, speaker_id, output)
      speaker_id_ptr = FFI::MemoryPointer.new(:int64)
      speaker_id_ptr.put(:int32, 0, speaker_id)
      if Old.decode_forward(
           length,
           phoneme_size,
           f0,
           phoneme,
           speaker_id_ptr,
           output
         )
        :voicevox_result_succeed
      else
        raise(Old.last_error_message)
      end
    end

    # @param [FFI::Pointer<String>] text
    # @param [Integer] speaker_id
    # @param [Voicevox::Core::VoicevoxTtsOptions] options
    # @param [FFI::Pointer<Integer>] output_binary_size
    # @param [FFI::Pointer<String>] output_wav
    # @return [Symbol]
    def voicevox_tts(text, speaker_id, options, output_binary_size, output_wav)
      if options[:kana]
        Old.voicevox_tts_from_kana(
          text,
          speaker_id,
          output_binary_size,
          output_wav
        )
      else
        Old.voicevox_tts(text, speaker_id, output_binary_size, output_wav)
      end
    end

    # @param [FFI::Pointer<String>] wav
    def voicevox_wav_free(wav)
      Old.voicevox_wav_free(wav)
    end

    # @param [Symbol] type
    # @param [String] text
    def voicevox_error_result_to_message(type)
      Old.voicevox_error_result_to_message(type)
    end

    def voicevox_make_default_tts_options
      options = Voicevox::Core::VoicevoxTtsOptions.new
      options[:kana] = false
      options
    end
    warn (
           "Failed to load new core (voicevox_core.dll, libvoicevox_core.so, libvoicevox_core.dylib), " +
             "using old core (core.dll, libcore.so, libcore.dylib)."
         )
  end
end
