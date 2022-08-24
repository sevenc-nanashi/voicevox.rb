# frozen_string_literal: true

require "etc"

class Voicevox
  class << self
    #
    # Voicevoxが初期化されていなかったらエラーを出す。
    #
    def initialize_required
      raise Voicevox::Error, "Voicevoxが初期化されていません" unless Voicevox.initialized?
    end

    #
    # last_error_messageのVoicevox::Errorをraiseします。
    #
    def failed
      raise Voicevox::Error,
        Voicevox::Core.last_error_message.force_encoding("UTF-8")
    end

    #
    # voicevox_result_codeに対応するエラーをraiseします。
    #
    # @param [Symbol] result voicevox_result_code。
    #
    def process_result(result)
      return if result == :voicevox_result_succeed

      raise Voicevox::CoreError.from_code(result)
    end

    #
    # 製品版Voicevoxのパスを返します。
    #
    # @return [String] Voicevoxへの絶対パス。
    # @return [nil] Voicevoxが見付からなかった場合。zip版やLinux版ではnilを返します。
    #
    def voicevox_path
      paths = if Gem.win_platform?
        [File.join(ENV.fetch("LOCALAPPDATA", ""), "Programs", "VOICEVOX")]
      else
        [
          "/Applications/VOICEVOX",
          "/Users/#{Etc.getlogin}/Library/Application Support/VOICEVOX",
        ]
      end
      paths.find { |path| Dir.exist?(path) }
    end
  end
end
