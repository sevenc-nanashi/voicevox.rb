require "etc"

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

  #
  # 製品版Voicevoxのパスを返します。
  #
  # @return [String] Voicevoxへの絶対パス。
  # @return [nil] Voicevoxが見付からなかった場合。zip版やLinux版ではnilを返します。
  #
  def self.voicevox_path
    paths = if Gem.win_platform?
        [File.join(ENV["LOCALAPPDATA"], "Programs", "VOICEVOX")]
      else
        [
          "/Applications/VOICEVOX",
          "/Users/#{Etc.getlogin}/Library/Application Support/VOICEVOX",
        ]
      end
    paths.find { |path| Dir.exist?(path) }
  end
end
