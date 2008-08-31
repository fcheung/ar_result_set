require 'ruby-debug'
module ActiveRecord
  module ResultSet
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        attr_accessor :result_set
        class << self
          alias_method_chain :find_every, :result_set
        end
      end
      #todo: figure which associations we need to include this in.
      ActiveRecord::Associations::AssociationCollection.send :include, AssociationProxyExtensions
      ActiveRecord::Associations::HasManyThroughAssociation.send :include, AssociationProxyExtensions
      ActiveRecord::Associations::HasOneThroughAssociation.send :include, HasOneThroughExtension
    end

    module AssociationProxyExtensions      
      def self.included(base)
        base.alias_method_chain :find_target, :result_set
      end
      
      def find_target_with_result_set
        if @owner.result_set
          @owner.result_set.load @reflection.name
          @target          
        else
          find_target_without_result_set
        end
      end
    end
    
    #This is a bit of a kludge: HasOneThrough descends from HasManyThrough.
    #find_target calls super and then just returns the first item. However our find_target is override
    #to load it for everyone and then return the target (so in the case of HasOneThrough a single object)
    #HasOneThrough then calls first on that object and goes capow
    module HasOneThroughExtension
      def find_target
        if @owner.result_set
          @owner.result_set.load @reflection.name
          #this is a bit subtle - the load will have called set_xxx_target which will have created a 
          #new instance of the association proxy  - return that value (our @target is still nil. boo)
          ivar = "@#{@reflection.name}"
          association = @owner.instance_variable_get ivar
          association.nil? ? [] : [association.target]
        else
          find_target_without_result_set
        end
      end
    end
    
    class ResultSetProxy
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }
      undef_method :select #this is Kernel#select (ie the IO one)
      
      def initialize(records, klass)
        @records = records
        @klass = klass
        @records.each {|r| r.result_set = self}
      end
    
      def records
        @records
      end      
      
      def method_missing(name, *args)
        if block_given?
          @records.send(name, *args) { |*block_args| yield(*block_args) }
        else
          @records.send(name, *args)
        end
      end
      
      def load(associations)
        @klass.send :preload_associations, @records, associations
        self
      end
    end
    
    module ClassMethods
      def find_every_with_result_set(*args)
        ResultSetProxy.new(find_every_without_result_set(*args), self)
      end
    end
  end
end

