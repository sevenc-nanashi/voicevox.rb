class Voicevox
  #
  # Voicevoxが初期化されていなかったらエラーを出す。
  #
  def self.initialize_required
    raise Voicevox::Error, "Voicevoxが初期化されていません" unless initialized?
  end

  #
  # last_error_messageのVoicevox::Errorをraiseします。
  #
  def self.failed
    raise Voicevox::Error,
          Voicevox::Core.last_error_message.force_encoding("UTF-8")
  end

  #
  # voicevox_result_codeに対応するエラーをraiseします。
  #
  # @param [Symbol] result voicevox_result_code。
  #
  def self.process_result(result)
    return if result == :voicevox_result_succeed

    message = Voicevox::Core.voicevox_error_result_to_message(result).force_encoding("UTF-8")
    raise Voicevox::Error,
          "#{message} (#{result})"
  end
end
