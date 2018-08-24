require_relative 'lib/ducktape/version'

Gem::Specification.new do |s|
  s.name          = 'ducktape'
  s.version       = Ducktape::VERSION
  s.summary       = 'Truly outrageous bindable attributes'
  s.description   = 'Truly outrageous bindable attributes'
  s.license       = 'MIT'
  s.authors       = %w'SilverPhoenix99 P3t3rU5'
  s.email         = %w'silver.phoenix99@gmail.com pedro.at.miranda@gmail.com'
  s.homepage      = 'https://github.com/SilverPhoenix99/ducktape'
  s.require_paths = %w'lib'
  s.files         = Dir['{lib/**/*.rb,*.md}']
  s.add_dependency 'facets', '~> 3.1'
  s.add_dependency 'whittle', '~> 0.0'
  s.add_dependency 'ref', '~> 2.0'
  s.add_development_dependency 'rspec', '~> 3.7'
  s.add_development_dependency 'simplecov', '~> 0.16'
  s.post_install_message = <<-eos
+----------------------------------------------------------------------------+
  Thank you for choosing Ducktape.

  ==========================================================================
  #{Ducktape::VERSION} Changes:
    - Added Bindable::bind method to wrap BindingSource construction.
    - Added support for Range validation in bindable attributes.
    - Internal refactorings.

  If you find any bugs, please report them on
    https://github.com/SilverPhoenix99/ducktape/issues

+----------------------------------------------------------------------------+
  eos
end