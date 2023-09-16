# frozen_string_literal: true

require "json"
require "delegate"

module Voicevox
  #
  # ユーザー辞書。
  #
  class UserDict < Delegator
    # @private
    attr_reader :pointer

    # @private
    def __getobj__
      json_ptr = FFI::MemoryPointer.new(:pointer)
      Voicevox.process_result Core.voicevox_user_dict_to_json(
                                @pointer,
                                json_ptr
                              )
      json = json_ptr.read_pointer.read_string
      Core.voicevox_json_free(json_ptr.read_pointer)
      json_ptr.free
      ret =
        JSON
          .parse(json, symbolize_names: true)
          .to_h { |uuid, word| [uuid.to_s, Word.from_hash(word)] }
      ret.freeze
      ret
    end

    #
    # ユーザー辞書を構築する。
    #
    def initialize
      @pointer =
        FFI::AutoPointer.new(
          Core.voicevox_user_dict_new,
          Core.method(:voicevox_user_dict_delete)
        )
    end

    #
    # ユーザー辞書にファイルを読み込ませる。
    #
    # @param [String] path ファイルのパス。
    # @return [void]
    #
    def load(path)
      Voicevox.process_resultCore.voicevox_user_dict_load(@pointer, path)
    end

    #
    # ユーザー辞書をファイルに保存する。
    #
    # @param [String] path ファイルのパス。
    # @return [void]
    #
    def save(path)
      Voicevox.process_result Core.voicevox_user_dict_save(@pointer, path)
    end

    #
    # ユーザー辞書に単語を追加する。
    #
    # @param [Word] word 追加する単語。
    # @return [String] 追加した単語のUUID。
    #
    def add_word(word)
      uuid_ptr = FFI::MemoryPointer.new(:uint8, 16)
      Voicevox.process_result Core.voicevox_user_dict_add_word(
                                @pointer,
                                word.to_struct,
                                uuid_ptr
                              )
      uuid =
        uuid_ptr
          .read_array_of_type(:uint8, :read_uint8, 16)
          .map { |x| x.to_s(16).rjust(2, "0") }
          .join
      uuid =
        "#{uuid[0..7]}-#{uuid[8..11]}-#{uuid[12..15]}-#{uuid[16..19]}-#{uuid[20..]}"
      uuid_ptr.free
      uuid
    end

    #
    # ユーザー辞書の単語を更新する。
    #
    # @param [String] uuid 更新する単語のUUID。
    # @param [Word] word 更新する単語。
    # @return [void]
    #
    def update_word(uuid, word)
      uuid = uuid.gsub("-", "")
      uuid_ptr = FFI::MemoryPointer.new(:uint8, 16)
      uuid_ptr.write_array_of_type(
        :uint8,
        :put_uint8,
        uuid.scan(/../).map(&:hex)
      )
      Voicevox.process_result Core.voicevox_user_dict_update_word(
                                @pointer,
                                uuid_ptr,
                                word.to_struct
                              )
      uuid_ptr.free
    end

    #
    # ユーザー辞書から単語を削除する。
    #
    # @param [String] uuid 削除する単語のUUID。
    # @return [void]
    #
    def remove_word(uuid)
      uuid = uuid.gsub("-", "")
      uuid_ptr = FFI::MemoryPointer.new(:uint8, 16)
      uuid_ptr.write_array_of_type(
        :uint8,
        :put_uint8,
        uuid.scan(/../).map(&:hex)
      )
      Voicevox.process_result Core.voicevox_user_dict_remove_word(
                                @pointer,
                                uuid_ptr
                              )
      uuid_ptr.free
    end

    #
    # ユーザー辞書の単語。
    #
    class Word
      # @return [String] 表記。
      attr_accessor :surface
      # @return [String] 読み。
      #   発音として有効なカタカナである必要がある。
      attr_accessor :pronunciation
      # @return [Integer] アクセント型。
      #   0からモーラ数。
      attr_accessor :accent_type
      # @return [:proper_noun, :common_noun, :verb, :adjective, :suffix] 単語の種類。
      attr_accessor :word_type
      # @return [Integer] 優先度。
      #   0から10。
      attr_accessor :priority

      #
      # ユーザー辞書の単語を構築する。
      #
      def initialize(
        surface,
        pronunciation,
        accent_type: 0,
        word_type: :proper_noun,
        priority: 5
      )
        @surface = surface
        @pronunciation = pronunciation
        @accent_type = accent_type
        @word_type = word_type
        @priority = priority
      end

      # @private
      def to_struct
        word = Core.voicevox_user_dict_word_make(@surface, @pronunciation)
        word[:accent_type] = @accent_type
        word[:word_type] = :"voicevox_user_dict_word_type_#{@word_type}"
        word[:priority] = @priority
        word
      end

      # @private
      def self.from_hash(hash)
        new(
          hash[:surface],
          hash[:pronunciation],
          accent_type: hash[:accent_type],
          word_type: hash[:word_type].downcase.to_sym,
          priority: hash[:priority]
        )
      end
    end
  end
end
