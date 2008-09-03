require 'ruby-debug'
module ActiveRecord
  module ResultSet
    
    def detach!
      return unless self.result_set
      self.result_set.delete self
      self.result_set = nil
    end
    
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        attr_accessor :result_set
        class << self
          alias_method_chain :find_every, :result_set
          alias_method_chain :preload_has_and_belongs_to_many_association, :reset
          alias_method_chain :preload_has_many_association, :reset
        end
      end
      #todo: figure which associations we need to include this in.
      ActiveRecord::Associations::AssociationProxy.send :include, AssociationProxyExtensions
      ActiveRecord::Associations::AssociationCollection.send :include, AssociationCollectionExtensions
      ActiveRecord::Associations::BelongsToAssociation.send :include, SingularAssociationExtension
      ActiveRecord::Associations::HasOneAssociation.send :include, SingularAssociationExtension
      ActiveRecord::Associations::HasManyThroughAssociation.send :include, AssociationCollectionExtensions
      ActiveRecord::Associations::HasOneThroughAssociation.send :include, SingularAssociationExtension
      ActiveRecord::Associations::HasOneThroughAssociation.send :include, HasOneThroughExtension
    end

    module AssociationProxyExtensions
        
      def find_target_with_result_set
        if @owner.result_set && @owner.result_set.length > 1 && !@reflection.options[:limit]
          @owner.result_set.load @reflection.name
          return_target_after_preload
        else
          find_target_without_result_set
        end
      end
    end
    
    module AssociationCollectionExtensions
      def self.included(base)
        base.alias_method_chain :find_target, :result_set
      end

      def return_target_after_preload
        @target
      end
    end
    
    module SingularAssociationExtension

      def self.included(base)
        base.alias_method_chain :find_target, :result_set
      end

      def return_target_after_preload
        #this is a bit subtle - the load will have called set_xxx_target which will have created a 
        #new instance of the association proxy  - return that value (our @target is still nil. boo)
        ivar = "@#{@reflection.name}"
        association = @owner.instance_variable_get ivar
        association.nil? ? nil : association.target
      end
    end
      
    
    #This is a bit of a kludge: HasOneThrough descends from HasManyThrough so
    #find_target calls super and then just returns the first item. However our find_target is overriden
    #to load it for everyone and then return the target (so in the case of HasOneThrough a single object)
    #HasOneThrough then calls first on that object and goes capow. Irritatingly we can't include our HMT module
    #in HMT without it also being included in HOT
    module HasOneThroughExtension
      def find_target
        result = find_target_with_result_set
        result.is_a?( Array) ? result : [result]
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
      
      #preload_assocations just appends to @target (which is fine normally since it's only ever
      # called on freshly instantiated objects. we however have to clear out @target in between goes)

      def preload_has_and_belongs_to_many_association_with_reset(records, reflection, preload_options={})
        reflection_name = reflection.name
        records.each {|record| record.send(reflection_name).send :reset_target!}
        preload_has_and_belongs_to_many_association_without_reset records, reflection, preload_options
      end
      
      def preload_has_many_association_with_reset(records, reflection, preload_options={})
        reflection_name = reflection.name
        records.each {|record| record.send(reflection_name).send :reset_target!}        
        preload_has_many_association_without_reset records, reflection, preload_options
      end
    end
  end
end

