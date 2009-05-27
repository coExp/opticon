require 'rubygems'

gem 'actionmailer'
require 'action_mailer'

module Opticon
  class Mailer < ::ActionMailer::Base
    # we use sendmail by default since it might just work out of the box
    # (:smtp which is the normal default definitely won't work without manual configuration)
    self.delivery_method = :sendmail 
    self.template_root = File.dirname(File.expand_path(__FILE__))+'/..'
  
    def failure_notification(service, message, recipients, from)
      subject = "HTTP Service Failure: #{service}"
      
      if ARGV.include?("-v")
        puts "Mailing notification:"
        puts "  TO:      #{recipients.inspect}"
        puts "  SUBJECT: #{subject}"
        puts "  FROM:    #{from}"
        puts "  SERVICE: #{service}"
        puts "  MESSAGE: #{message}"
      end
      
      self.recipients recipients
      self.from       from
      self.subject    subject
      self.body       :service => service, :message => message
    end
  end
end