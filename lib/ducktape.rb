# Although against rubygems recommendation, while version is < 1.0.0, an increase in the minor version number
# may represent an incompatible implementation with the previous minor version, which should have been
# represented by a major version number increase.

%w'
  set
  facets/ostruct
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
'.each { |f| require "ducktape/#{f}" }

%w'def_hookable'.each { |f| require "ext/#{f}" }