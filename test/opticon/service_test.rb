require File.dirname(__FILE__) + '/../test_helper.rb'

class Opticon::ServiceTest < Test::Unit::TestCase

  def setup
    Opticon.default_notifiers = Opticon::Notifier::Dummy.new
  end
  
  def test_initialize
    uri = "http://www.yahoo.com/"
    s = Opticon::Service.new(uri)
    
    assert_equal Opticon.default_notifiers, s.notifiers
    assert_equal uri, s.to_s
  end
  
  def test_test
    uri = "http://www.yahoo.com/"
    s = Opticon::Service.new(uri)
    
    assert !s.test(:responds_with_code, 200).failures?
    assert s.test(:responds_with_code, 400).failures?
    assert_equal 1, s.notifiers.first.notifications.size
    assert_kind_of Opticon::Failure::ResponseCodeTestFailure, s.notifiers.first.notifications.first
  end
  
  def test_string_convenience
    uri = "http://www.yahoo.com/"
    
    assert !uri.test(:responds_with_code, 200).failures?
    assert uri.test(:responds_with_code, 400).failures?
  end
  
  def test_test_block
    uri = "http://www.yahoo.com/"
    s = Opticon::Service.new(uri)
    
    s.test do
      test(:responds_with_code, 200)
      test(:responds_with_code, 400)
    end
    
    assert s.failures?
    assert_equal 1, s.notifiers.first.notifications.size
    assert_kind_of Opticon::Failure::ResponseCodeTestFailure, s.notifiers.first.notifications.first.first
  end
  
  def test_test_block_on_string
    uri = "http://www.yahoo.com/"
    
    uri.test do
      test(:responds_with_code, 200)
      test(:responds_with_code, 400)
    end
    
    assert uri.failures?
    assert_equal 1, uri.notifiers.first.notifications.size
    
    assert_kind_of Opticon::Failure::ResponseCodeTestFailure, uri.notifiers.first.notifications.first.first
  end
  
end
