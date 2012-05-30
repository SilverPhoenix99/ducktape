require 'version'

module Ducktape
  camelize = ->(f){ f.gsub(/(^|_)([^_]+)/) { |_| $2.capitalize } }

  %w'ducktape'.each do |dir|
    Dir["#{File.expand_path("../#{dir}", __FILE__)}/*.rb"].
      map  { |f| File.basename(f, File.extname(f)) }.
      each { |f| autoload camelize.(f), "#{dir}/#{f}" }
  end

  %w'def_hookable'.each { |f| require "ext/#{f}" }

end