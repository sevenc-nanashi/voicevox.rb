# frozen_string_literal: true

# ref: https://github.com/VOICEVOX/voicevox_core/blob/main/example/python/run.py

require "voicevox"
require "optparse"

def main(use_gpu:, text:, speaker_id:, cpu_num_threads:, openjtalk_dict:)
  # コアの初期化
  vv = Voicevox.new(openjtalk_dict, use_gpu: use_gpu, threads: cpu_num_threads, load_all_models: false)

  # 話者のロード
  vv.load_model(speaker_id)

  # 音声合成
  wavefmt = vv.tts(text, speaker_id)

  # 保存
  File.write("#{text}-#{speaker_id}.wav", wavefmt, mode: "wb")

  vv.finalize
end

if __FILE__ == $PROGRAM_NAME
  options = {
    use_gpu: false,
    text: nil,
    speaker_id: nil,
    cpu_num_threads: 0,
    openjtalk_dict: "open_jtalk_dic_utf_8-1.11"
  }
  parser = OptionParser.new
  parser.on("--[no-]use_gpu") { |v| options[:use_gpu] = v }
  parser.on("--text [TEXT]", String) { |v| options[:text] = v }
  parser.on("--speaker_id [ID]", Integer) { |v| options[:speaker_id] = v }
  parser.on("--cpu_num_threads [THREADS]", Integer) do |v|
    options[:cpu_num_threads] = v if v
  end
  parser.on("--openjtalk_dict [PATH]", String) do |v|
    options[:openjtalk_dict] = v if v
  end
  parser.parse!
  if options.values.any?(&:nil?)
    raise OptParse::MissingArgument,
          options.filter { |_k, v| v.nil? }.keys.join(", ")
  end
  main(**options)
end
