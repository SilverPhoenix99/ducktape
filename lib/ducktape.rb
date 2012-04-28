module Ducktape
  {
    :Bindable                  => 'bindable',
    :BindableAttribute         => 'bindable_attribute',
    :BindableAttributeMetadata => 'bindable_attribute_metadata',
    :BindingSource             => 'binding_source',
    :Hookable                  => 'hookable'
  }.each { |k, v| autoload k, "ducktape/#{v}" }
end