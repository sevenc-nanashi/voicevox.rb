# voicevox.rb / voicevox_coreの非公式ラッパー

oicevox.rbは[VOICEVOX/voicevox_core](https://github.com/VOICEVOX/voicevox_core)の非公式ラッパーです。

## 使い方

環境に合ったvoicevox_coreのライブラリをダウンロードし、Rubyから参照できるようにしてください。  

Windows環境の場合は、[RubyInstaller2のwiki](https://github.com/oneclick/rubyinstaller2/wiki/For-gem-developers#-dll-loading)を参照してください。

### 高レベルAPI

Voicevoxクラスには高レベルなAPIがあります。

サンプル：[examples/repl_wrapper.rb](./examples/repl_wrapper.rb)

### 低レベルAPI

Voicevox::Coreに[ffi/ffi](https://github.com/ffi/ffi)で包んだだけのAPIがあります。
型情報は[sig/voicevox/core.rbs](./sig/voicevox/core.rbs)を参照してください。

サンプル：[examples/repl_core.rb](./examples/repl_core.rb)

## ライセンス

LGPLv3でライセンスされています。[LICENSE](./LICENSE)を参照してください。
