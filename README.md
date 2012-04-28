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



Hookables
---------

BA comes with hooks. You can easily define a hook by using def_hook

     class X
       include Bindable
       include Hookable
       bindable :name, default: 'John', validate: [String, Symbol]
       def_hook
       def initialize(name)
         self.name = name
       end
     end

    