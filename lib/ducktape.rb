require 'ducktape/version'

module Ducktape
  {
    :Bindable                  => 'bindable',
    :BindableAttribute         => 'bindable_attribute',
    :BindableAttributeMetadata => 'bindable_attribute_metadata',
    :BindingSource             => 'binding_source',
    :Hookable                  => 'hookable',
    :HookableArray             => 'hookable_array'
  }.each { |k, v| autoload k, "ducktape/#{v}" }
end