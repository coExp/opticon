#!/usr/bin/env ruby                                                 
require 'rubygems'                                                  

#begin
#  gem 'opticon'
#rescue Gem::LoadError
#  # try to load local copy if gem is not available 
#  $: << File.dirname(__FILE__)+'/../lib'           
#end                                                


require "opticon/opticon-0.0.4/lib/opticon.rb"
#require 'opticon'
#require 'opticon_ext.rb'




# SEND_TO determines where notifications will be emailed.
#                                                        
# If you want to send to multiple mailboxes, you can specify an array of
# addresses like so:                                                    
#                                                                       
#   SEND_TO = ['robert@nowhere.foo', 'sally@nowhere.foo']               

SEND_TO = ['c@ant.com','w@ant.com','co.meulien@gmail.com']
#SEND_TO = 'co.meulien@gmail.com'

# Email notifications will show up as coming from the FROM address.
#                                                                  
# You may have to set the FROM value to be a real email address (e.g. your 
# email address). Otherwise your mail server may decide to drop Opticon's  
# notification messages.                                                   

FROM = "server@ant.com"


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


"http://www.ant.com".
        test(:responds_with_code, :success).
	test(:response_body_not_contains, /warning/i ).
	test(:response_body_not_contains, /error/i )

"http://rank.ant.com/fetch/http%3A%2F%2Fwww.google.com".
	test(:response_body_contains, "1", 10).
	test(:response_body_not_contains, /warning/i, 10 ).
	test(:response_body_not_contains, /error/i, 10 )

"http://ant.com/toolbar".
	test(:responds_with_code, :success).
	test(:response_body_not_contains, /warning/i ).
	test(:response_body_not_contains, /error/i )


#"http://ww.ant.com/guide"

#"http://yodanova.free.fr/index.php".
#	test(:response_body_contains, "YRSUT").
#	test(:response_body_not_contains, "YRSUT").
#	test(:response_body_not_contains, "Masi c est quoi ce bordel !!!")

#"http://rank.ant.com/fetch/http%3A%2F%2Fwww.yodanova.com".
#	test(:response_body_contains, "Invalid url").
#	test(:response_body_contains, /invalid url/i )
	#test(:response_body_contains, "Privacy Policy")
	#
#"http://www.yodanova.com/".
#        test(:responds_with_code, :success).
#        test(:response_body_contains, "Privacy Policy")




