# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "orthoses"
require "orthoses-yard"
task default: [:spec]

RSpec::Core::RakeTask.new(:spec)

namespace :rbs do
  desc "build RBS to sig/orthoses"
  task :build do
    Orthoses::Builder
      .new do
        use Orthoses::LoadRBS, paths: Dir.glob("sig/**/*.rbs")
        use Orthoses::CreateFileByName, depth: 2, to: "sig"
        use Orthoses::Filter do |name|
          name.start_with?("Voicevox")
        end
        use Orthoses::Mixin
        use Orthoses::Constant
        use Orthoses::Walk, root: "Voicevox"
        use Orthoses::YARD, parse: ["lib/**/*.rb"]
        run -> { require_relative "lib/voicevox" }
      end
      .call
  end
end
