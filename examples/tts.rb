require "voicevox"

puts "== Initialize"
Voicevox::Core.initialize(false, 4, true)

size_ptr = FFI::MemoryPointer.new(:int)
return_ptr = FFI::MemoryPointer.new(:pointer)

puts "== Loading dict"
p Voicevox::Core.voicevox_load_openjtalk_dict(ENV.fetch("OPENJTALK_DICT") { raise "OPENJTALK_DICT is not set" })
puts "== TTS"
print "> "
p Voicevox::Core.voicevox_tts(gets, 0, size_ptr, return_ptr)
puts "== Done"

puts "== Export"
data_ptr = return_ptr.read_pointer
data = data_ptr.read_string(size_ptr.read_int)

size_ptr.free
return_ptr.free

File.write("./output.wav", data, mode: "wb")
