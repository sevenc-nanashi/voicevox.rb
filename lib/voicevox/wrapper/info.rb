# frozen_string_literal: true

require "json"

module Voicevox
  module_function

  def core_version
    @core_version ||= Voicevox::Core.voicevox_get_version
  end

  SupportedDevices = Struct.new(:cpu, :cuda, :dml)

  def supported_devices
    if @supported_devices.nil?
      pointer = FFI::MemoryPointer.new(:pointer)
      Voicevox::Core.voicevox_create_supported_devices_json(pointer)
      supported_devices =
        JSON.parse(pointer.read_pointer.read_string, symbolize_names: true)

      @supported_devices =
        SupportedDevices.new(
          supported_devices[:cpu],
          supported_devices[:cuda],
          supported_devices[:dml]
        )
    end
    @supported_devices
  end
end
