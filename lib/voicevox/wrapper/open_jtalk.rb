# frozen_string_literal: true

module Voicevox
  class OpenJtalk
    # @private
    attr_reader :pointer
    def initialize(open_jtalk_dic_dir)
      pointer = FFI::MemoryPointer.new(Core::Uintptr)
      Voicevox.process_result Core.voicevox_open_jtalk_rc_new(
                                open_jtalk_dic_dir,
                                pointer
                              )

      @pointer =
        FFI::AutoPointer.new(
          pointer.read_pointer,
          Core.method(:voicevox_open_jtalk_rc_delete)
        )
    end

    def user_dict=(user_dict)
      Voicevox.process_result Core.voicevox_open_jtalk_rc_use_user_dict(
                                @pointer,
                                user_dict.pointer
                              )
    end
  end
end
