# frozen_string_literal: true
require "json"

module Voicevox
  #
  # 音声合成用のクエリ。
  #
  class AudioQuery
    # @return [Array<AccentPhrase>] アクセント句のリスト。
    attr_accessor :accent_phrases
    # @return [Float] 全体の話速。
    attr_accessor :speed_scale
    # @return [Float] 全体の音高。
    attr_accessor :pitch_scale
    # @return [Float] 全体の抑揚。
    attr_accessor :intonation_scale
    # @return [Float] 全体の音量。
    attr_accessor :volume_scale
    # @return [Float] 音声の前の無音時間。
    attr_accessor :pre_phoneme_length
    # @return [Float] 音声の後の無音時間。
    attr_accessor :post_phoneme_length
    # @return [Integer] 音声データの出力サンプリングレート。
    attr_accessor :output_sampling_rate
    # @return [Boolean] 音声データをステレオ出力するか否か。
    attr_accessor :output_stereo
    # @return [String] AquesTalkライクな読み仮名。
    attr_reader :kana

    # @private
    def initialize(query)
      @accent_phrases = query[:accent_phrases].map { |ap| AccentPhrase.new ap }
      @speed_scale = query[:speed_scale]
      @pitch_scale = query[:pitch_scale]
      @intonation_scale = query[:intonation_scale]
      @volume_scale = query[:volume_scale]
      @pre_phoneme_length = query[:pre_phoneme_length]
      @post_phoneme_length = query[:post_phoneme_length]
      @output_sampling_rate = query[:output_sampling_rate]
      @output_stereo = query[:output_stereo]
      @kana = query[:kana]
    end

    #
    # JSONからAudioQueryを生成します。
    # @param [String] json AudioQueryのJSON。
    # @return [AccentPhrase]
    #
    def self.from_json(json)
      new JSON.parse(json, symbolize_names: true)
    end

    #
    # AudioQueryをHashにします。
    #
    # @return [Hash]
    #
    def to_hash
      {
        accent_phrases: @accent_phrases.map(&:to_hash),
        pitch_scale: @pitch_scale,
        speed_scale: @speed_scale,
        intonation_scale: @intonation_scale,
        volume_scale: @volume_scale,
        pre_phoneme_length: @pre_phoneme_length,
        post_phoneme_length: @post_phoneme_length,
        output_sampling_rate: @output_sampling_rate,
        output_stereo: @output_stereo,
        kana: @kana
      }
    end

    alias to_h to_hash

    #
    # AudioQueryをjsonにします。
    #
    # @return [String]
    #
    def to_json(...)
      to_hash.to_json(...)
    end

    # @private
    def eql?(other)
      to_hash.eql?(other.to_hash)
    end

    # @private
    def hash
      to_hash.hash
    end

    # @private
    alias == eql?
  end

  #
  # アクセント句ごとの情報。
  #
  class AccentPhrase
    # @return [Array<Mora>] モーラのリスト。
    attr_reader :moras
    # @return [Integer] アクセント箇所。
    attr_reader :accent
    # @return [Mora, nil] 後ろに無音を付けるかどうか。
    attr_reader :pause_mora
    # @return [Boolean] 疑問系かどうか。
    attr_reader :is_interrogative
    alias interrogative? is_interrogative

    # @private
    def initialize(query)
      @moras = query[:moras].map { |ap| Mora.new ap }
      @accent = query[:accent]
      @pause_mora = query[:pause_mora] && Mora.new(query[:pause_mora])
      @is_interrogative = query[:is_interrogative]
    end

    #
    # JSONからAccentPhraseを生成します。
    # @param [String] json AccentPhraseの情報を持つJSON。
    # @return [AccentPhrase]
    #
    def self.from_json(json)
      new JSON.parse(json, symbolize_names: true)
    end

    #
    # AccentPhraseをHashにします。
    #
    # @return [Hash]
    #
    def to_hash
      {
        moras: @moras.map(&:to_hash),
        accent: @accent,
        pause_mora: @pause_mora&.to_hash,
        is_interrogative: @is_interrogative
      }
    end

    alias to_h to_hash

    #
    # AccentPhraseをJSONにします。
    #
    # @return [String]
    #
    def to_json(...)
      to_hash.to_json(...)
    end

    # @private
    def eql?(other)
      other.is_a?(self.class) && other.to_hash == to_hash
    end

    # @private
    def hash
      to_hash.hash
    end

    # @private
    alias == eql?

    #
    # モーラ（子音＋母音）ごとの情報。
    #
    class Mora
      # @return [String] 文字。
      attr_reader :text
      # @return [String] 子音の音素。
      attr_reader :consonant
      # @return [Float] 子音の音長。
      attr_reader :consonant_length
      # @return [String] 母音の音素。
      attr_reader :vowel
      # @return [Float] 母音の音長。
      attr_reader :vowel_length
      # @return [Float] 音高。
      attr_reader :pitch

      def initialize(query)
        @text = query[:text]
        @consonant = query[:consonant]
        @consonant_length = query[:consonant_length]
        @vowel = query[:vowel]
        @vowel_length = query[:vowel_length]
        @pitch = query[:pitch]
      end

      #
      # MoraをHashにします。
      #
      # @return [Hash]
      #
      def to_hash
        {
          text: @text,
          consonant: @consonant,
          consonant_length: @consonant_length,
          vowel: @vowel,
          vowel_length: @vowel_length,
          pitch: @pitch
        }
      end

      alias to_h to_hash

      #
      # MoraをJSONにします。
      # @return [String]
      #
      def to_json(...)
        to_hash.to_json(...)
      end

      # @private
      def eql?(other)
        @text == other.text &&
          @consonant == other.consonant &&
          @consonant_length == other.consonant_length &&
          @vowel == other.vowel &&
          @vowel_length == other.vowel_length &&
          @pitch == other.pitch
      end

      # @private
      def hash
        to_hash.hash
      end

      # @private
      alias == eql?
    end
  end
end
