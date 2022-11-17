# frozen_string_literal: true

require_relative "lib/ip_shield/version"

Gem::Specification.new do |spec|
  spec.name = "ip_shield"
  spec.version = IpShield::VERSION
  spec.authors = ["Abdullah Janjua"]
  spec.email = ["AbdullahJanjuauk@gmail.com"]

  spec.summary = "do it: Write a short summary, because RubyGems requires one."
  spec.description = "do it: Write a longer description or delete this line."
  spec.homepage = "https://github.com/DevAbdullahUk/roda-IPShield"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/DevAbdullahUk/roda-IPShield"
  # spec.metadata["changelog_uri"] = "do it: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
