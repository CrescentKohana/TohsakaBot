# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name        = 'TohsakaBot'
  spec.version     = '1.0'
  spec.authors     = ['Marko Leinikka']
  spec.summary     = 'A multipurpose Discord bot.'
  spec.description = 'A multipurpose Discord bot made with Ruby with a Rails web component: TohsakaWeb. Also called as Rin.'
  spec.homepage    = 'https://rin.luukuton.fi'
  spec.license     = 'Zlib'

  spec.required_ruby_version = '>= 2.7.0'
  spec.files         = ['lib/bot.rb']
  spec.require_paths = ['lib']
end
