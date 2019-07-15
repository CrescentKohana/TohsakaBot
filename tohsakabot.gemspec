# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "TohsakaBot"
  spec.version       = '1.0'
  spec.authors       = ["Marko Leinikka"]
  spec.email         = ["youremail@yourdomain.com"]
  spec.summary       = %q{A multipurpose Discord bot.}
  spec.description   = %q{Longer description of your project.}
  spec.homepage      = "https://luukuton.fi/tohsakabot/"
  spec.license       = "MIT"

  spec.files         = ['lib/bot.rb']
  spec.executables   = ['bin/NAME']
  spec.test_files    = ['tests/test_NAME.rb']
  spec.require_paths = ["lib"]
end
