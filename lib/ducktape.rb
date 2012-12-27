module Ducktape
  # Although against rubygems recommendation, while version is < 1.0.0, an increase in the minor version number
  # may represent an incompatible implementation with the previous minor version, which should have been
  # represented by a major version number increase.

  VERSION = '0.3.2'

  camelize = ->(f){ f.gsub(/(^|_)([^_]+)/) { |_| $2.capitalize } }

  %w'ducktape'.each do |dir|
    Dir["#{File.expand_path("../#{dir}", __FILE__)}/*.rb"].
      map  { |f| File.basename(f, File.extname(f)) }.
      each { |f| autoload camelize.(f), "#{dir}/#{f}" }
  end

  %w'def_hookable'.each { |f| require "ext/#{f}" }

end