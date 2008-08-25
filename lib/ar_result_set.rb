module ActiveRecord
  module ResultSet
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class << self
          alias_method_chain :find_every, :result_set
        end
      end
    end
    
    class ResultSetProxy
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }
    
      def initialize(records)
        @records = records
      end
    
      def records
        @records
      end
    
      def method_missing(name, *args, &block)
        records.send(name, *args, &block)
      end
    end
    
    module ClassMethods
      def find_every_with_result_set(*args)
        ResultSetProxy.new(find_every_without_result_set(*args))
      end
    end
  end
end

