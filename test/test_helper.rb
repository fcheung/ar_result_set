$KCODE = 'u'
require 'jcode'
require 'test/unit'
require 'rubygems'
require 'activesupport'
require 'active_record'
require 'active_record/fixtures'

RAILS_ENV = 'test'

Dependencies.load_paths << File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib/"))

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))

RAILS_DEFAULT_LOGGER = ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

ActiveRecord::Base.configurations = {'test' => config['sqlite']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

load(File.dirname(__FILE__) + "/schema.rb")

require 'ar_result_set'
require File.dirname(__FILE__) + '/../init'

ActiveRecord::Base.connection.class.class_eval do
  IGNORED_SQL = [/^PRAGMA/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/]

  def execute_with_counting(sql, name = nil, &block)
    $query_count ||= 0
    $query_count  += 1 unless IGNORED_SQL.any? { |r| sql =~ r }
    execute_without_counting(sql, name, &block)
  end

  alias_method_chain :execute, :counting
end

class Test::Unit::TestCase
  fixtures :all
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end

  def assert_queries(num = 1)
    $query_count = 0
    yield
  ensure
    assert_equal num, $query_count, "#{$query_count} instead of #{num} queries were executed."
  end

  def assert_no_queries(&block)
    assert_queries(0, &block)
  end

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
