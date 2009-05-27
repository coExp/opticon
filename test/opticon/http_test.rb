require File.dirname(__FILE__) + '/../test_helper.rb'

class Opticon::HTTPTest < Test::Unit::TestCase
  
  def setup
    @test_uri = URI.parse("http://google.com")
    @test_https_uri = URI.parse("https://www.google.com/accounts/ServiceLogin")
    
    @http = TestHTTP.new
    @http.extend Opticon::HTTP
    
    @http.uri = @test_uri
  end
  
  def test_get
    assert_kind_of Net::HTTPResponse, @http.get(@test_uri)
  end
  
  def test_response
    assert_kind_of Net::HTTPResponse, @http.response
  end

  def test_response_reuse
    response = @http.response
    
    assert_equal response.object_id, @http.response.object_id
    
    @http.uri = "http://www.google.ca"
    
    response2 = @http.response
    assert_not_equal response.object_id, @http.response.object_id
    assert_equal response2.object_id, @http.response.object_id
  end
  
  def test_https_get
    @http.uri = @test_https_uri
    assert_kind_of Net::HTTPResponse, @http.response
    assert_match "Sign in", @http.response.body
  end
  
  class TestHTTP
    include Opticon::HTTP
    attr_accessor :uri
  end
end
