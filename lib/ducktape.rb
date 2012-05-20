require 'version'

module Ducktape
  camelize = ->(f){ f.gsub(/(^|_)([^_]+)/) { |_| $2.capitalize } }

  Dir["#{File.expand_path('../ducktape', __FILE__)}/*.rb"].
    map  { |f| File.basename(f, File.extname(f)) }.
    each { |f| autoload camelize.(f), "ducktape/#{f}" }

  #%w'bindable
  #   bindable_attribute
  #   bindable_attribute_metadata
  #   binding_source
  #   hookable
  #   hookable_array
  #   hookable_collection
  #   hookable_hash'.each { |f| autoload camelize.(f), "ducktape/#{f}" }
end