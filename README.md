# voicevox.rb / voicevox_coreの非公式ラッパー
[![Gem](https://img.shields.io/gem/dt/voicevox.rb?logo=rubygems&logoColor=fff&label=Downloads)](https://rubygems.org/gems/voicevox.rb) [![Docs](https://img.shields.io/badge/Docs-rubydoc.info-blue)](https://rubydoc.info/gems/voicevox.rb)

voicevox.rbは[VOICEVOX/voicevox_core](https://github.com/VOICEVOX/voicevox_core)の非公式ラッパーです。

```rb
dict_path = ENV["OPENJTALK_DICT_PATH"]
vv = Voicevox.new(dict_path, load_all_models: false)
character = Voicevox.characters[0].styles[0]
character.load
print "> "
text = gets.chomp
data = vv.tts(text, character)

File.write("#{__dir__}/outputs/#{Process.pid}_#{i}.wav", data, mode: "wb")
```

## 使い方

環境に合ったvoicevox_coreのライブラリをダウンロードし、Rubyから参照できるようにしてください。
[voicevox_coreの環境構築ガイド](https://github.com/VOICEVOX/voicevox_core#%E7%92%B0%E5%A2%83%E6%A7%8B%E7%AF%89)も参考にしてください。

Windows環境の場合は、[RubyInstaller2のwiki](https://github.com/oneclick/rubyinstaller2/wiki/For-gem-developers#-dll-loading)を参照してください。

### 高レベルAPI

Voicevoxクラスには高レベルなAPIがあります。

サンプル：[examples/repl_wrapper.rb](./examples/repl_wrapper.rb)

### 低レベルAPI

Voicevox::Coreに[ffi/ffi](https://github.com/ffi/ffi)で包んだだけのAPIがあります。
型情報は[sig/voicevox/core.rbs](./sig/voicevox/core.rbs)を参照してください。

サンプル：[examples/repl_core.rb](./examples/repl_core.rb)

## インストール

```
gem install voicevox.rb

bundle add voicevox.rb
```

## ライセンス

MITライセンスが適用されています。[LICENSE](./LICENSE)を参照してください。
