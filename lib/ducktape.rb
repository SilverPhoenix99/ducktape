require 'ducktape/version'

module Ducktape
  camelize = ->(f){ f.gsub(/(^|_)([^_]+)/) { |_| $2.capitalize } }

  %w'bindable
     bindable_attribute
     bindable_attribute_metadata
     binding_source
     hookable
     hookable_array
     hookable_collection_base
     hookable_hash'.each { |f| autoload camelize.(f), "ducktape/#{f}" }
end