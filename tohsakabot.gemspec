# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "TohsakaBot"
  spec.version       = '1.0'
  spec.authors       = ["Marko Leinikka"]
  spec.email         = [""]
  spec.summary       = %q{A multipurpose Discord bot.}
  spec.description   = %q{A multipurpose Discord bot made with Ruby mainly for my own use.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = ['lib/bot.rb']
  spec.require_paths = ["lib"]
end
