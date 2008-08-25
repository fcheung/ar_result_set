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
class Test::Unit::TestCase
  fixtures :all
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
