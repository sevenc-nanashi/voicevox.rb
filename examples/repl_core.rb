# frozen_string_literal: true

require "voicevox"
require "reline"

dict_path =
  ENV.fetch("OPENJTALK_DICT") do
    raise("OPENJTALK_DICTを設定してください。") unless Voicevox.voicevox_path

    "#{Voicevox.voicevox_path}/pyopenjtalk/open_jtalk_dic_utf_8-1.11"
  end
print "== 初期化中... "
options = Voicevox::Core.voicevox_make_default_initialize_options
options[:openjtalk_dict_path] = FFI::MemoryPointer.from_string(dict_path)
Voicevox::Core.voicevox_initialize(options)
Voicevox::Core.voicevox_load_model(0)

puts "完了"
i = 0
loop do
  text = Reline.readline("> ")
  break unless text

  print "生成中... "

  size_ptr = FFI::MemoryPointer.new(:int)
  return_ptr = FFI::MemoryPointer.new(:pointer)
  Voicevox::Core.voicevox_tts(
    text,
    0,
    Voicevox::Core.voicevox_make_default_tts_options,
    size_ptr,
    return_ptr
  )
  print "完了：#{size_ptr.read_int}バイト、アドレス：#{return_ptr.read_pointer.address.to_s(16)}"
  data_ptr = return_ptr.read_pointer
  data = data_ptr.read_string(size_ptr.read_int)

  size_ptr.free
  Voicevox::Core.voicevox_wav_free(data_ptr)

  i += 1
  File.write("#{__dir__}/outputs/#{Process.pid}_#{i}.wav", data, mode: "wb")
  puts "、#{Process.pid}_#{i}.wav"
end
print "\nファイナライズ中... "
Voicevox::Core.voicevox_finalize
puts "完了"
