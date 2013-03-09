lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'ducktape/version'

Gem::Specification.new do |s|
  s.name          = 'ducktape'
  s.version       = Ducktape::VERSION
  s.summary       = 'Truly outrageous bindable attributes'
  s.description   = 'Truly outrageous bindable attributes'
  s.license       = 'MIT'
  s.authors       = %w'SilverPhoenix99 P3t3rU5'
  s.email         = %w'silver.phoenix99@gmail.com pedro.megastore@gmail.com'
  s.homepage      = 'https://github.com/SilverPhoenix99/ducktape'
  s.require_paths = %w'lib'
  s.files         = Dir['{lib/**/*.rb,*.md}']
  s.add_dependency 'facets', '~> 2.9'
  s.add_dependency 'whittle', '~> 0.0'
  s.add_dependency 'ref', '~> 1'
  s.add_development_dependency 'rspec'
  s.post_install_message = <<-eos
+----------------------------------------------------------------------------+
  Thank you for choosing Ducktape.

  ==========================================================================
  #{Ducktape::VERSION} Changes:
    - This version is compatible with version 0.3.x.
    - Added path expression to binding sources.

  If you like what you see, support us on Pledgie:
    http://www.pledgie.com/campaigns/18955

  If you find any bugs, please report them on
    https://github.com/SilverPhoenix99/ducktape/issues

+----------------------------------------------------------------------------+
  eos
end