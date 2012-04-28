Ducktape
=========

Trully outrageous bindable attributes

To install gem:

gem install ducktape

Usage Samples
-------------

Bindable attributes (BA) work just like normal attributes. To assign a BA to a class you just need to declare it like a attr_accessor:

     require 'bindables'
	 
     class X
       include Bindable

       bindable :name

       def initialize(name)
         self.name = name
       end
     end

You can do validation on a BA, for example in the last example we could validate :name as a String or a Symbol:

     class X
       include Bindable
       
       bindable :name, validate: [String, Symbol]
       
       def initialize(name)
         self.name = name
       end
     end

Validation works with procs as well:

     class X
       include Bindable
     
       bindable :name, validate: 
     
       def initialize(name)
         self.name = name
       end
     end

You can also set default values for your BA:


     class X
       include Bindable
     
       bindable :name, default: 'John', validate: [String, Symbol]
     
       def initialize(name)
         self.name = name
       end
     end
     

Then you can watch for changes in a BA
	 
	 def attribute_changed(event, owner, attr_name, old_value, new_value)
	   puts "The instance #{owner.object_id.to_s(16)} of class #{owner.class} called the event #{event} and so, changed the attribute #{attr_name} from #{old_value.inspect} to #{new_value.inspect}"
	 end

	 class X
	   include Bindable
	   
	   bindable :name, validate: [String, Symbol]
	   bindable :age, validate: Integer
	   bindable :points, validate: Integer
	   
	   def initialize(name, age, points)
	     self.name = name
		 self.age = age
		 self.points = points
		 %w'name age points'.each { |k, v| on_changed k, &method(:attribute_changed) }
	   end
	 end
	 
	 x = X.new('Richad', 23, 150)
	 
	 x.on_changed 'name', &->(_, _, _, _, new_value) { puts "Hello #{new_value}!"}
	 
	 x.name = 'Richard'

On `on_changed` hook call the arguments are:
+ the name of the event (`'on_changed'`)
+ the owner of the BA (the instance of `X` that sent the message),
+ the name of the BA (name, age, points, etc...),
+ the old value
+ the new value
	 
Hookables
---------

BA comes with hooks. You can easily define a hook by using def_hook

     class X
       include Bindable
       include Hookable
	   
       bindable :name, default: 'John', validate: [String, Symbol]
	   
       def_hook :on_loaded
	   
       def initialize(name)
         self.name = name
       end
     end

    