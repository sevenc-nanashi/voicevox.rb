# frozen_string_literal: true

require "ffi"
require "fiddle"
require "English"

Fiddle.dlopen(ENV["ORT_DLL_PATH"]) if ENV["ORT_DLL_PATH"]

# rubocop:disable Naming/ConstantName

module Voicevox
  #
  # voicevox_coreの薄いラッパー。
  #
  module Core
    extend FFI::Library

    ffi_lib %w[voicevox_core.dll libvoicevox_core.dylib libvoicevox_core.so]

    Uintptr =
      if Fiddle::SIZEOF_VOIDP == 8
        :uint64
      else
        :uint32
      end

    enum FFI::NativeType::INT32,
         :voicevox_acceleration_mode,
         {
           voicevox_acceleration_mode_auto: 0,
           voicevox_acceleration_mode_cpu: 1,
           voicevox_acceleration_mode_gpu: 2
         }.to_a.flatten
    VoicevoxAccelerationMode = :voicevox_acceleration_mode

    enum :voicevox_result_code,
         {
           voicevox_result_ok: 0,
           voicevox_result_not_loaded_openjtalk_dict_error: 1,
           voicevox_result_load_model_error: 2,
           voicevox_result_get_supported_devices_error: 3,
           voicevox_result_gpu_support_error: 4,
           voicevox_result_load_metas_error: 5,
           voicevox_result_invalid_style_id_error: 6,
           voicevox_result_invalid_model_id_error: 7,
           voicevox_result_inference_error: 8,
           voicevox_result_extract_full_context_label_error: 11,
           voicevox_result_invalid_utf8_input_error: 12,
           voicevox_result_parse_kana_error: 13,
           voicevox_result_invalid_audio_query_error: 14,
           voicevox_result_invalid_accent_phrase_error: 15,
           voicevox_result_open_file_error: 16,
           voicevox_result_vvm_model_read_error: 17,
           voicevox_result_already_loaded_model_error: 18,
           voicevox_result_unloaded_model_error: 19,
           voicevox_result_load_user_dict_error: 20,
           voicevox_result_save_user_dict_error: 21,
           voicevox_result_unknown_user_dict_word_error: 22,
           voicevox_result_use_user_dict_error: 23,
           voicevox_result_invalid_user_dict_word_error: 24,
           voicevox_result_invalid_uuid_error: 25
         }.to_a.flatten
    VoicevoxResultCode = :voicevox_result_code

    enum :voicevox_user_dict_word_type,
         {
           voicevox_user_dict_word_type_proper_noun: 0,
           voicevox_user_dict_word_type_common_noun: 1,
           voicevox_user_dict_word_type_verb: 2,
           voicevox_user_dict_word_type_adjective: 3,
           voicevox_user_dict_word_type_suffix: 4
         }.to_a.flatten
    VoicevoxUserDictWordType = :voicevox_user_dict_word_type

    # class VoicevoxOpenJtalkRc < FFI::Struct
    # end
    VoicevoxOpenJtalkRc = :pointer

    # class VoicevoxSynthesizer < FFI::Struct
    # end
    VoicevoxSynthesizer = :pointer

    # class VoicevoxUserDict < FFI::Struct
    # end
    VoicevoxUserDict = :pointer

    # class VoicevoxVoiceModel < FFI::Struct
    # end
    VoicevoxVoiceModel = :pointer

    VoicevoxVoiceModelId = :string

    class VoicevoxInitializeOptions < FFI::Struct
      layout(
        {
          acceleration_mode: VoicevoxAccelerationMode,
          cpu_num_threads: :uint16,
          load_all_models: :bool
        }
      )
    end

    VoicevoxStyleId = :uint32

    class VoicevoxAudioQueryOptions < FFI::Struct
      layout({ kana: :bool })
    end

    class VoicevoxAccentPhraseOptions < FFI::Struct
      layout({ kana: :bool })
    end

    class VoicevoxSynthesisOptions < FFI::Struct
      layout({ enable_interrogative_upspeak: :bool })
    end

    class VoicevoxTtsOptions < FFI::Struct
      layout({ kana: :bool, enable_interrogative_upspeak: :bool })
    end

    class VoicevoxUserDictWord < FFI::Struct
      layout(
        {
          surface: :string,
          pronunciation: :string,
          accent_type: Uintptr,
          word_type: VoicevoxUserDictWordType,
          priority: :uint32
        }
      )
    end

    attach_function :voicevox_make_default_initialize_options,
                    {},
                    VoicevoxInitializeOptions.by_value

    attach_function :voicevox_get_version, {}, :string

    attach_function :voicevox_make_default_audio_query_options,
                    {},
                    VoicevoxAudioQueryOptions.by_value

    attach_function :voicevox_make_default_synthesis_options,
                    {},
                    VoicevoxSynthesisOptions.by_value

    attach_function :voicevox_make_default_accent_phrases_options,
                    {},
                    VoicevoxAccentPhraseOptions.by_value

    attach_function :voicevox_make_default_synthesis_options,
                    {},
                    VoicevoxSynthesisOptions.by_value

    attach_function :voicevox_make_default_tts_options, {}, VoicevoxTtsOptions.by_value

    attach_function :voicevox_open_jtalk_rc_new,
                    {
                      open_jtalk_dic_dir: :string,
                      out_open_jtalk: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_open_jtalk_rc_use_user_dict,
                    {
                      open_jtalk_rc: VoicevoxOpenJtalkRc,
                      user_dict: VoicevoxUserDict
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_open_jtalk_rc_delete,
                    { open_jtalk_rc: VoicevoxOpenJtalkRc }.values,
                    :void

    attach_function :voicevox_voice_model_new_from_path,
                    { path: :string, out_model: :pointer }.values,
                    VoicevoxResultCode

    attach_function :voicevox_voice_model_id,
                    { model: VoicevoxVoiceModel }.values,
                    VoicevoxVoiceModelId

    attach_function :voicevox_voice_model_get_metas_json,
                    { model: VoicevoxVoiceModel }.values,
                    :string

    attach_function :voicevox_voice_model_delete,
                    { model: VoicevoxVoiceModel }.values,
                    :void

    attach_function :voicevox_synthesizer_new_with_initialize,
                    {
                      open_jtalk: VoicevoxOpenJtalkRc,
                      options: VoicevoxInitializeOptions.by_value,
                      out_synthesizer: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_synthesizer_delete,
                    { synthesizer: VoicevoxSynthesizer }.values,
                    :void

    attach_function :voicevox_synthesizer_load_voice_model,
                    {
                      synthesizer: VoicevoxSynthesizer,
                      model: VoicevoxVoiceModel
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_synthesizer_unload_voice_model,
                    {
                      synthesizer: VoicevoxSynthesizer,
                      model_id: VoicevoxVoiceModelId
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_synthesizer_is_gpu_mode,
                    { synthesizer: VoicevoxSynthesizer }.values,
                    :bool

    attach_function :voicevox_synthesizer_is_loaded_voice_model,
                    {
                      synthesizer: VoicevoxSynthesizer,
                      model_id: VoicevoxVoiceModelId
                    }.values,
                    :bool

    attach_function :voicevox_synthesizer_create_metas_json,
                    { synthesizer: VoicevoxSynthesizer }.values,
                    :string

    attach_function :voicevox_create_supported_devices_json,
                    { output_supported_devices_json: :pointer }.values,
                    VoicevoxResultCode

    attach_function :voicevox_synthesizer_create_audio_query,
                    {
                      synthesizer: VoicevoxSynthesizer,
                      text: :string,
                      style_id: VoicevoxStyleId,
                      options: VoicevoxAudioQueryOptions.by_value,
                      out_audio_query_json: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_synthesizer_create_accent_phrases,
                    {
                      synthesizer: VoicevoxSynthesizer,
                      text: :string,
                      style_id: VoicevoxStyleId,
                      options: VoicevoxAudioQueryOptions.by_value,
                      out_accent_phrases_json: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_synthesizer_replace_mora_data,
                    {
                      synthesizer: VoicevoxSynthesizer,
                      accent_phrases_json: :string,
                      style_id: VoicevoxStyleId,
                      out_accent_phrases_json: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_synthesizer_replace_phoneme_length,
                    {
                      synthesizer: VoicevoxSynthesizer,
                      accent_phrases_json: :string,
                      style_id: VoicevoxStyleId,
                      out_accent_phrases_json: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_synthesizer_replace_mora_pitch,
                    {
                      synthesizer: VoicevoxSynthesizer,
                      accent_phrases_json: :string,
                      style_id: VoicevoxStyleId,
                      out_accent_phrases_json: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_synthesizer_synthesis,
                    {
                      synthesizer: VoicevoxSynthesizer,
                      audio_query_json: :string,
                      style_id: VoicevoxStyleId,
                      options: VoicevoxSynthesisOptions.by_value,
                      output_wav_length: :pointer,
                      output_wav: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_synthesizer_tts,
                    {
                      synthesizer: VoicevoxSynthesizer,
                      text: :string,
                      style_id: VoicevoxStyleId,
                      options: VoicevoxTtsOptions.by_value,
                      output_wav_length: :pointer,
                      output_wav: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_json_free, { json: :pointer }.values, :void

    attach_function :voicevox_wav_free, { json: :pointer }.values, :void

    attach_function :voicevox_error_result_to_message,
                    { result: VoicevoxResultCode }.values,
                    :string

    attach_function :voicevox_user_dict_word_make,
                    { surface: :string, pronunciation: :string }.values,
                    VoicevoxUserDictWord.by_value

    attach_function :voicevox_user_dict_new, {}, VoicevoxUserDict

    attach_function :voicevox_user_dict_load,
                    { user_dict: VoicevoxUserDict, path: :string }.values,
                    VoicevoxResultCode

    attach_function :voicevox_user_dict_add_word,
                    {
                      user_dict: VoicevoxUserDict,
                      word: VoicevoxUserDictWord.by_ref,
                      output_word_uuid: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_user_dict_update_word,
                    {
                      user_dict: VoicevoxUserDict,
                      word_uuid: :pointer,
                      word: VoicevoxUserDictWord.by_ref
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_user_dict_remove_word,
                    { user_dict: VoicevoxUserDict, word_uuid: :pointer }.values,
                    VoicevoxResultCode

    attach_function :voicevox_user_dict_to_json,
                    {
                      user_dict: VoicevoxUserDict,
                      output_json: :pointer
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_user_dict_import,
                    {
                      user_dict: VoicevoxUserDict,
                      other_dict: VoicevoxUserDict
                    }.values,
                    VoicevoxResultCode

    attach_function :voicevox_user_dict_save,
                    { user_dict: VoicevoxUserDict, path: :string }.values,
                    VoicevoxResultCode

    attach_function :voicevox_user_dict_delete,
                    { user_dict: VoicevoxUserDict }.values,
                    :void
  end
end

# rubocop:enable Naming/ConstantName
