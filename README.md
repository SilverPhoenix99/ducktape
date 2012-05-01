Ducktape
========

A [truly outrageous](http://youtu.be/dSPb56-_I98) gem for bindable attributes.

To install:

```
gem install ducktape
```

Bindable attributes
-------------------

Bindable attributes (BA) work just like normal attributes. To assign a BA to a class you just need to declare it like an attr_accessor:

```ruby
require 'ducktape'

class X
  include Ducktape::Bindable

  bindable :name

  def initialize(name)
    self.name = name
  end
end
```

### Binding

BA's, like the name hints, can be bound to other BA's:

```ruby
class X
  include Ducktape::Bindable

  bindable :name
end

class Y
  include Ducktape::Bindable

  bindable :other_name
end

x = X.new

y = Y.new
y.other_name = Ducktape::BindingSource.new(x, :name)

x.name = 'Richard'

puts y.other_name
```

Output:
```ruby
=> "Richard"
```

There are three types of direction for `BindingSource`:
* `:both` - (default) Changes apply in both directions.
* `:forward` - Changes only apply from the binding source BA to the destination BA.
* `:reverse` - Changes only apply from the destination BA to the binding source BA.

Here's an example of `:reverse` binding (very similar to the previous):

```ruby
class X
  include Ducktape::Bindable

  bindable :name
end

class Y
  include Ducktape::Bindable

  bindable :other_name
end

x = X.new

y = Y.new
y.other_name = Ducktape::BindingSource.new(x, :name, :reverse)

y.other_name = 'Mary'

puts x.name
puts y.other_name
```

Output:
```ruby
=> "Mary"
=> "Mary"
```

But if you then do:

```ruby
x.name = 'John'

puts x.name
puts y.other_name
```

the output will be:
```ruby
=> "John"
=> "Mary"
```

### Removing bindings

To remove a previously defined binding call the `#unbind_source(attr_name)` method. To remove all bindings for a given object, call the `#clear_bindings` method.

### Read only / Write only

BA's can be read-only and write-only. Read-only BA's are useful for reverse only bindings or when the object itself changes the value through the protected method `#set_value`. On the other hand, write-only BA's are best used as sources, though the owner object can call the `#get_value` to get the value of the BA.

To define a BA as read-only or write-only, use the `:access` modifier.

Here's an example of read-only and write-only BA's:

```ruby
class X
  include Ducktape::Bindable

  bindable :name, access: :readonly

  #no need for this now
  #
  #def initialize(name = 'John')
  #  self.name = name
  #end
end

class Y
  include Ducktape::Bindable

  bindable :other_name, access: :writeonly
end

x = X.new
y = Y.new

y.other_name = Ducktape::BindingSource.new(x, :name, :reverse)
y.other_name = 'Alex'

puts x.name
```

Output:
```ruby
=> "Alex"
```

### Default values

You can set default values for your BA:

```ruby
class X
  include Ducktape::Bindable

  bindable :name, default: 'John'

  #we don't need to do this now:
  #
  #def initialize(name = 'John')
  #  self.name = name
  #end
end
```

### Validation

You can do validation on a BA.

Following the last example we could validate `:name` as a String or a Symbol:

```ruby
class X
  include Ducktape::Bindable

  bindable :name, validate: [String, Symbol]

  def initialize(name)
	self.name = name
  end
end
```

Validation works with procs as well. In this case, a proc must have a single parameter which is the new value.

```ruby
class X
  include Ducktape::Bindable

  bindable :name, validate: ->(value){ !value.nil? }

  def initialize(name)
	self.name = name
  end
end
```

Validation also works with any kind of objects. For example, to make an enumerable:

```ruby
class X
  include Ducktape::Bindable

  # place attribute will only accept assignment to these three symbols:
  bindable :place, default: :first, validate: [:first, :middle, :last]
end
```

In short, you can have a single object or a proc, or an array of objects/procs to validate. If any of them returns "true" (i.e., not `nil` and not `false`), then the new value is accepted. Otherwise it will throw an `InvalidAttributeValueError`.

### Coercion

While validation can help knowing when things aren't what we expect, sometimes what we really want is to force a value to remain in a domain. This is where coercion comes in.

For example, we would like for a float value to remain between 0 and 1, inclusively. If the value goes out of scope, then we want to clamp it to remain between 0 and 1. Additionally, we want other numerical types to be valid, and converted to floats.

```ruby
class X
  include Ducktape::Bindable

  bindable :my_float,
    validate: Numeric,
    default: 0.0,
    coerce: ->(owner, value) { value = value.to_f; value < 0.0 ? 0.0 : (value > 1.0 ? 1.0 : value) }
end

x = X.new
x.my_float = 2.0

puts x.my_float
```

The output would be:
```ruby
=> 1.0
```

Note that if validation is defined, then it will only happen after coercion is applied.

### Hookable change notifications

You can watch for changes in a BA by using the public instance method `#on_changed(attr_name, &block)`. Here's an example:

```ruby
def attribute_changed(event, owner, attr_name, new_value, old_value)
  puts "#{owner.class}<#{owner.object_id.to_s(16)}> called the event #{event.inspect} and changed the attribute #{attr_name.inspect} from #{old_value.inspect} to #{new_value.inspect}"
end

class X
  include Ducktape::Bindable

  bindable :name, validate: [String, Symbol]
  bindable :age, validate: Integer
  bindable :points, validate: Integer

  def initialize(name, age, points)
	self.name = name
	self.age = age
	self.points = points

	# You can hook for any method available
	%w'name age points'.each { |k, v| on_changed k, &method(:attribute_changed) }
  end
end

# oops, a misspelling...
x = X.new('Richad', 23, 150)

# It's also useful to see changes outside of the class:
x.on_changed 'name', &->(_, _, _, _, new_value) { puts "Hello #{new_value}!" }

x.name = 'Richard'
```

After calling `#name=`, the output should be something like:

```ruby
=> "Hello Richard!"
=> "X<14e35b4> called the event \"on_changed\" and changed the attribute \"name\" from \"Richad\" to \"Richard\""
```

The `on_changed` hook has the following arguments:
* the name of the event (in this case, `'on_changed'`)
* the caller/owner of the BA (the instance that sent the message),
* the name of the BA (`name`, `age`, `points`, etc...),
* the new value,
* the old value

Hooks
-----

Has you might have seen, Ducktape comes with hooks, which is what powers the `on_changed` for bindable attributes.
You can easily define a hook by using `def_hook`:

```ruby
def called_load(event, caller)
  puts "#{caller.class}<#{caller.object_id.to_s(16)}> called #{event.inspect}"
end

class X
  include Ducktape::Hookable

  def_hook :on_loaded #define one or more hooks

  def load
	call_hooks(:on_loaded)
  end
end

x = X.new

x.on_loaded &method(:called_load)

#if we didn't create a hook with def_hook we could still use:
#x.add_hook :on_loaded, &method(:called_load)

x.load
```

The output should be:
```ruby
=> "X<14e35b4> called \"on_loaded\""
```

### Hookable arrays



Future work
===========
* Arrays and hashes passed to BA's should check for element changes (collections with hooks).
* Multi sourced BA's.