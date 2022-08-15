require "voicevox"
require "reline"

dict_path = ENV.fetch("OPENJTALK_DICT") {
  Voicevox.voicevox_path ? Voicevox.voicevox_path + "/pyopenjtalk/open_jtalk_dic_utf_8-1.11" : raise("OPENJTALK_DICTを設定してください。")
}
print "== 初期化中... "
vv = Voicevox.new
vv.init(load_all_models: false)
vv.load_openjtalk_dict(dict_path)
character = Voicevox.characters[0].styles[0]
character.load

puts "完了：#{vv.gpu? ? "GPU" : "CPU"}モード"
i = 0
loop do
  text = Reline.readline "> "
  break unless text
  print "生成中... "

  data = vv.tts(text, character)
  print "完了：#{data.bytesize}バイト"

  i += 1
  File.write("#{__dir__}/outputs/#{Process.pid}_#{i}.wav", data, mode: "wb")
  puts "、#{Process.pid}_#{i}.wav"
end
vv.finalize
