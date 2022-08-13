require "ffi"

module Voicevox::Core
  extend FFI::Library

  attach_function :initialize, [:bool, :int, :bool], :bool

  attach_function :load_model, [:int64], :bool

  attach_function :is_model_loaded, [:int64], :bool

  attach_function :finalize, [], :void
end
