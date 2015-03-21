require_relative 'lib/ducktape/version'

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
  s.add_dependency 'facets', '~> 3'
  s.add_dependency 'whittle', '~> 0.0'
  s.add_dependency 'ref', '~> 1'
  s.add_development_dependency 'rspec'
  s.post_install_message = <<-eos
+----------------------------------------------------------------------------+
  Thank you for choosing Ducktape.

  ==========================================================================
  #{Ducktape::VERSION} Changes:
    - Added path expression to binding sources.

  If you find any bugs, please report them on
    https://github.com/SilverPhoenix99/ducktape/issues

+----------------------------------------------------------------------------+
  eos
end