require File.dirname(__FILE__) + '/../test_helper.rb'

class Opticon::HTTPTest < Test::Unit::TestCase

  def setup
  end
  
  def test_response_code_tester
    tester = Opticon::Tester::ResponseCodeTester.new
    tester.uri = "http://www.yahoo.com"
    
    assert tester.run(:success)
    assert tester.run(200)
    assert tester.run([200, 302])
    assert !tester.run(:server_error)
  end
  
  def test_response_code_tester_failure
    tester = Opticon::Tester::ResponseCodeTester.new
    tester.uri = "http://www.yahoo.com/alskjdflaksjflkasjfklsTHIS_PAGE_DOESNT_EXIST"
    
    assert tester.run(404)
    assert !tester.run(:success)
    assert_kind_of Opticon::Failure::ResponseCodeTestFailure, tester.failure
    assert_equal 404.to_s, tester.failure.response.code.to_s
  end
  
  def test_response_code_tester_cant_connect
    tester = Opticon::Tester::ResponseCodeTester.new
    tester.uri = "http://there.is.no.such.server.foobarblah:1234/test"
    
    assert !tester.run(:success)
    assert_kind_of Opticon::Failure::ConnectionFailure, tester.failure
    
    tester = Opticon::Tester::ResponseCodeTester.new
    tester.uri = "http://localhost:65489789"
    
    assert !tester.run(:success)
    assert_kind_of Opticon::Failure::ConnectionFailure, tester.failure
  end
  
  def test_content_tester_string
    tester = Opticon::Tester::ContentTester.new
    
    tester.uri = "http://code.google.com/p/opticon/"
    assert tester.run("matt.zukowski"), tester.failure
    assert_nil tester.failure
    
    bad_string = "THIS STRING DOESNT EXIST IN OPTICON's GOOGLE CODE PAGE!!!"
    assert !tester.run(bad_string), tester.failure
    assert_equal bad_string, tester.failure.condition
  end
  
  def test_content_tester_regexp
    tester = Opticon::Tester::ContentTester.new
    
    tester.uri = "http://code.google.com/p/opticon/"
    assert tester.run(/gnu general public license v[0-9]/i), tester.failure
    assert_nil tester.failure
    
    bad_regexp = /klasjfkljasdlkfjasklfjslkdfj/
    assert !tester.run(bad_regexp), tester.failure
    assert_equal bad_regexp, tester.failure.condition
  end
  
  def test_content_tester_fail_on_redirect
    tester = Opticon::Tester::ContentTester.new
  
    tester.uri = "http://google.com/"    
    # google will try to redirect to http://www.google.com/
    assert_equal 301, tester.response.code.to_i
    assert !tester.run("Google Search"), tester.failure
    assert_equal "http://www.google.com/", tester.failure.response['location']
  end
  
end
