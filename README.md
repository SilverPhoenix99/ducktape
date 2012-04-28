Ducktape
=========

Bindable attributes

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
     
       bindable :name, validate: [String, Symbol]
     
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

	 class X
	   include Bindable
	   
	   bindable :name, validate: [String, Symbol]
	   bindable :age, validate: Integer
	   bindable :points, validate: Integer
	   
	   def iitialize(name, age, points)
	     self.name = name
		 self.age = age
		 self.points = points
		 {
            :name   => :name_changed,
            :age    => :age_changed,
            :points => :points_changed
         }.each do |k, v|
                on_changed k, &method(v)
	   end
	   
	   def name_changed(_, _, _, _, _)
	     puts "your name changed to #{self.name}" 
	   end
	   
	   def age_changed(_, _, _, _, _)
	     puts "your age changed to #{self.age}" 
	   end
	   
	   def points_changed(_, _, _, _, _)
	     puts "your points changed to #{self.points}" 
	   end
	 end

On `on_changed` hook call the arguments are the name of the event (`'on_changed'`), the owner of the BA (the class `X`), the name of the BA (name, age, points, etc...), the old value and the new value
	 
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

    