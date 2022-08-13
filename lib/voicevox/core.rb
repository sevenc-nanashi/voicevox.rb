require "ffi"
begin
  require "ruby_installer"
rescue LoadError
  # 何もせず無視
else
  # Voicevox製品版のcore.dllを使う
  RubyInstaller::Runtime.add_dll_directory(ENV["LOCALAPPDATA"] + "/programs/voicevox")
end

module Voicevox::Core
  extend FFI::Library
  ffi_lib ["core.dll", "libcore.dylib", "libcore.so"]

  enum :voicevox_result_code, [
    :voicevox_result_succeed, 0,
    :voicevox_result_not_loaded_openjtalk_dict, 1,
    :voicevox_result_failed_load_model, 2,
    :voicevox_result_failed_get_supported_devices, 3,
    :voicevox_result_cant_gpu_support, 4,
    :voicevox_result_failed_load_metas, 5,
    :voicevox_result_uninitialized_status, 6,
    :voicevox_result_invalid_speaker_id, 7,
    :voicevox_result_invalid_model_index, 8,
    :voicevox_result_inference_failed, 9,
    :voicevox_result_failed_extract_full_context_label, 10,
    :voicevox_result_invalid_utf8_input, 11,
    :voicevox_result_failed_parse_kana, 12,
  ]

  attach_function :initialize, [:bool, :int, :bool], :bool

  attach_function :load_model, [:int64], :bool

  attach_function :is_model_loaded, [:int64], :bool

  attach_function :finalize, [], :void

  attach_function :metas, [], :string

  attach_function :last_error_message, [], :string

  attach_function :supported_devices, [], :string

  attach_function :yukarin_s_forward, [:int64, :pointer, :pointer, :pointer], :bool

  attach_function :yukarin_sa_forward, [:int64, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :bool

  attach_function :decode_forward, [:int64, :int64, :pointer, :pointer, :pointer, :pointer], :bool

  attach_function :voicevox_load_openjtalk_dict, [:string], :voicevox_result_code

  attach_function :voicevox_tts, [:string, :int64, :pointer, :pointer], :voicevox_result_code

  attach_function :voicevox_tts_from_kana, [:string, :int64, :pointer, :pointer], :voicevox_result_code

  attach_function :voicevox_wav_free, [:pointer], :void

  attach_function :voicevox_error_result_to_message, [:voicevox_result_code], :string
end
