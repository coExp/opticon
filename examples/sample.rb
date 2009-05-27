#!/usr/bin/env ruby
require 'rubygems'

begin
  gem 'opticon'
rescue Gem::LoadError
  # try to load local copy if gem is not available 
  $: << File.dirname(__FILE__)+'/../lib'
end

require 'opticon'

# SEND_TO determines where notifications will be emailed.
#
# If you want to send to multiple mailboxes, you can specify an array of
# addresses like so:
# 
#   SEND_TO = ['robert@nowhere.foo', 'sally@nowhere.foo']

SEND_TO = "sample@nowhere.foo"


# Email notifications will show up as coming from the FROM address.
#
# You may have to set the FROM value to be a real email address (e.g. your 
# email address). Otherwise your mail server may decide to drop Opticon's
# notification messages.

FROM = "opticon@nowhere.foo"


# You don't have to change anything on this next line. This configures the 
# default notification behaviour for Opticon, which is to email failures to the
# addresses you configured above.

Opticon.default_notifiers << Opticon::Notifier::Email.new(SEND_TO, :from => FROM)

# You may need to configure the Mailer with your mail server info. Here's how to
# use an SMTP mail server (unless you do this, local sendmail will be used used
# by default):
# 
#   Opticon::Mailer.smtp_settings = {
#       :address => 'mail.nowhere.foo',
#       :username => 'johnny',
#       :password => 'topsecret'
#     }
# 
# See http://api.rubyonrails.com/classes/ActionMailer/Base.html for more details
# on setting up the mailer.


# Now you can set up some tests. Note that this is just plain Ruby code, formatted
# a bit strangely (note the dot at the end of each line -- we are calling the test()
# method on the URI string, and then on the result of each successive test).
# Here are some examples:

"http://www.yahoo.com/".
  # check that the HTTP response code is in the 200 range
  test(:responds_with_code, :success).
  # check that the page includes the string "Privacy Policy"
  test(:response_body_contains, "Privacy Policy")  

"http://google.com".
  # Google will try to redirect to http://www.google.com/
  test(:responds_with_code, 301) 
  # Note that currently there is no test for checking where you are being
  # redirected to. This functionality will be added in the future.


# Alternatively, you can pack your tests into a a block (this is now the
# preferred method):

"http://www.yahoo.com/".test do
  # check that the HTTP response code is in the 200 range
  test(:responds_with_code, :success)
  # check that the page includes the string "Privacy Policy"
  test(:response_body_contains, "Privacy Policy") 
end


# For a comprehensive guide on configuring and using Opticon, please see:
#
#   http://code.google.com/p/opticon/wiki/ConfiguringOpticon
#
