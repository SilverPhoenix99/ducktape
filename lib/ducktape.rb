module Ducktape
  ROOT = File.expand_path('../ducktape', __FILE__)

  {
    :Bindable                  => 'bindable',
    :BindableAttribute         => 'bindable_attribute',
    :BindableAttributeMetadata => 'bindable_attribute_metadata',
    :BindingSource             => 'binding_source',
    :Hookable                  => 'hookable'
  }.each { |k, v| autoload k, "#{ROOT}/#{v}" }
end