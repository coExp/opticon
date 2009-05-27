require File.dirname(__FILE__) + '/../test_helper.rb'
require 'net/http'
require 'opticon/failure'
require 'opticon/notifier'
require 'opticon/mailer'

class Opticon::HTTPTest < Test::Unit::TestCase

  class DummyFailure < Opticon::Failure::Base
    def failure_message
      "This is a test!"
    end
  end

  def setup
    @failure = DummyFailure.new("http://nowhere.test/test", 200, nil)
  end
  
  def test_failure_notification
    email = Opticon::Mailer.create_failure_notification(@failure.uri, @failure.failure_message, "test@test.ruby", "opticon@test.ruby")
    assert_match(@failure.uri, email.subject)
    assert_equal("test@test.ruby", email.to.first)
    assert_match(@failure.uri, email.body)
    assert_match(@failure.failure_message, email.body)
  end
end