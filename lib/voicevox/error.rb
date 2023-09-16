# frozen_string_literal: true

require "objspace"

module Voicevox
  #
  # Voicevox関連のエラー。
  #
  class Error < StandardError
  end

  #
  # Voicevoxのコアで発生したエラー。
  #
  class CoreError < Error
    # @return [Symbol] エラーコード。
    attr_reader :code

    def initialize
      message =
        Voicevox::Core.voicevox_error_result_to_message(
          self.class.code
        ).force_encoding("UTF-8")
      @code = code
      super(message)
    end

    class << self
      attr_reader :code

      def from_code(code)
        ObjectSpace
          .each_object(Class)
          .find { |klass| klass < self && klass.code == code }
          .new
      end
    end

    class NotLoadedOpenjtalkDict < CoreError
      @code = :voicevox_result_not_loaded_openjtalk_dict_error
    end
    class LoadModel < CoreError
      @code = :voicevox_result_load_model_error
    end
    class GetSupportedDevices < CoreError
      @code = :voicevox_result_get_supported_devices_error
    end
    class GpuSupport < CoreError
      @code = :voicevox_result_gpu_support_error
    end
    class LoadMetas < CoreError
      @code = :voicevox_result_load_metas_error
    end
    class InvalidStyleId < CoreError
      @code = :voicevox_result_invalid_style_id_error
    end
    class InvalidModelId < CoreError
      @code = :voicevox_result_invalid_model_id_error
    end
    class Inference < CoreError
      @code = :voicevox_result_inference_error
    end
    class ExtractFullContextLabel < CoreError
      @code = :voicevox_result_extract_full_context_label_error
    end
    class InvalidUtf8Input < CoreError
      @code = :voicevox_result_invalid_utf8_input_error
    end
    class ParseKana < CoreError
      @code = :voicevox_result_parse_kana_error
    end
    class InvalidAudioQuery < CoreError
      @code = :voicevox_result_invalid_audio_query_error
    end
    class InvalidAccentPhrase < CoreError
      @code = :voicevox_result_invalid_accent_phrase_error
    end
    class OpenFile < CoreError
      @code = :voicevox_result_open_file_error
    end
    class VvmModelRead < CoreError
      @code = :voicevox_result_vvm_model_read_error
    end
    class AlreadyLoadedModel < CoreError
      @code = :voicevox_result_already_loaded_model_error
    end
    class UnloadedModel < CoreError
      @code = :voicevox_result_unloaded_model_error
    end
    class LoadUserDict < CoreError
      @code = :voicevox_result_load_user_dict_error
    end
    class SaveUserDict < CoreError
      @code = :voicevox_result_save_user_dict_error
    end
    class UnknownUserDictWord < CoreError
      @code = :voicevox_result_unknown_user_dict_word_error
    end
    class UseUserDict < CoreError
      @code = :voicevox_result_use_user_dict_error
    end
    class InvalidUserDictWord < CoreError
      @code = :voicevox_result_invalid_user_dict_word_error
    end
    class InvalidUuid < CoreError
      @code = :voicevox_result_invalid_uuid_error
    end
  end
end
