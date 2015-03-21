%w'
  set
  facets/ostruct
  facets/array/extract_options
  ref
  whittle
'.each { |f| require f }

%w'
  version
  hookable
  expression/literal_exp
  expression/binary_op_exp
  expression/identifier_exp
  expression/indexer_exp
  expression/property_exp
  expression/qualified_exp
  expression/binding_parser
  converter
  link
  binding_source
  bindable_attribute_metadata
  bindable_attribute
  bindable
  ext/def_hookable
'.each { |f| require_relative "ducktape/#{f}" }