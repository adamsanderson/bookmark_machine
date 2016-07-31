$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'bookmark_machine'

class BookmarkMachineTest < Minitest::Test
  include BookmarkMachine
  
  FIXTURE_DIR = File.dirname(__FILE__)  + "/fixtures/"
  
  def fixture_path(name)
    FIXTURE_DIR + name
  end
  
  def fixture(name)
    IO.read(fixture_path(name))
  end
end