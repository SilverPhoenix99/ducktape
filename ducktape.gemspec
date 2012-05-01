lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'ducktape/version'

Gem::Specification.new do |s|
  s.name          = 'ducktape'
  s.version       = Ducktape::VERSION
  s.summary       = 'Truly outrageous bindable attributes'
  s.description   = 'Truly outrageous bindable attributes'
  s.authors       = %w'SilverPhoenix99 P3t3rU5'
  s.email         = %w'silver.phoenix99@gmail.com pedro.megastore@gmail.com'
  s.homepage      = 'https://github.com/SilverPhoenix99/ducktape'
  s.require_paths = %w'lib'
  s.files         = Dir['{lib/**/*.rb,*.md}']
end