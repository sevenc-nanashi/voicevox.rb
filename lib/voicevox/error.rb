require "objspace"

class Voicevox
  #
  # Voicevox関連のエラー。
  #
  class Error < StandardError; end

  #
  # Voicevoxのコアで発生したエラー。
  #
  class CoreError < Error
    # @return [Symbol] エラーコード。
    attr_reader :code

    def initialize
      message = Voicevox::Core.voicevox_error_result_to_message(self.class.code).force_encoding("UTF-8")
      @code = code
      super(message)
    end

    class << self
      attr_reader :code

      def from_code(code)
        ObjectSpace.each_object(Class).find { |klass| klass < self && klass.code == code }.new()
      end
    end

    class NotLoadedOpenjtalkDict < Voicevox::CoreError
      @code = :voicevox_result_not_loaded_openjtalk_dict
    end

    class FailedLoadModel < Voicevox::CoreError
      @code = :voicevox_result_failed_load_model
    end

    class FailedGetSupportedDevices < Voicevox::CoreError
      @code = :voicevox_result_failed_get_supported_devices
    end

    class CantGpuSupport < Voicevox::CoreError
      @code = :voicevox_result_cant_gpu_support
    end

    class FailedLoadMetas < Voicevox::CoreError
      @code = :voicevox_result_failed_load_metas
    end

    class UninitializedStatus < Voicevox::CoreError
      @code = :voicevox_result_uninitialized_status
    end

    class InvalidSpeakerId < Voicevox::CoreError
      @code = :voicevox_result_invalid_speaker_id
    end

    class InvalidModelIndex < Voicevox::CoreError
      @code = :voicevox_result_invalid_model_index
    end

    class InferenceFailed < Voicevox::CoreError
      @code = :voicevox_result_inference_failed
    end

    class FailedExtractFullContextLabel < Voicevox::CoreError
      @code = :voicevox_result_failed_extract_full_context_label
    end

    class InvalidUtf8Input < Voicevox::CoreError
      @code = :voicevox_result_invalid_utf8_input
    end

    class FailedParseKana < Voicevox::CoreError
      @code = :voicevox_result_failed_parse_kana
    end
  end
end
