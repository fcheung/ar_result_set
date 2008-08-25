require 'ar_result_set'

ActiveRecord::Base.class_eval do
  include ActiveRecord::ResultSet
end
