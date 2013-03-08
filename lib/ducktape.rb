%w'
  set
  facets/ostruct
'.each { |f| require f }

%w'
  version
  hookable
  binding_source
  bindable_attribute_metadata
  bindable_attribute
  bindable
'.each { |f| require "ducktape/#{f}" }

%w'def_hookable'.each { |f| require "ext/#{f}" }