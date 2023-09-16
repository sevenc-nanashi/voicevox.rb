# frozen_string_literal: true

require "etc"

module Voicevox
  module_function
  #
  # @private
  # voicevox_result_codeに対応するエラーをraiseする。
  #
  # @param [Symbol] result voicevox_result_code。
  #
  def process_result(result)
    return if result == :voicevox_result_ok
    raise "Assert: result.is_a?(Symbol), got: #{result.class}" unless result.is_a?(Symbol)

    raise Voicevox::CoreError.from_code(result)
  end
end
