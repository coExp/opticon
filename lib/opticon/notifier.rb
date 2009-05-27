require File.dirname(File.expand_path(__FILE__))+'/mailer'
require 'pstore'

module Opticon
  module Notifier
    # Sends failure notifications via email to the given list of recipients.
    # 
    # To set options, configure Opticon::Mailer the same way you
    # would any other ActionMailer. For example, to send via SMTP:
    # 
    #   Opticon::Mailer.delivery_method = :smtp
    #   
    #   Opticon::Mailer.server_settings = {
    #     :address => "mail.nowhere.foo",
    #     :domain => "nowhere.foo",
    #     :authentication => :login,
    #     :user_name => "mail_user",
    #     :password => "topsecret"
    #   }
    # 
    class Email
      attr_accessor :recipients, :from
      
      # The same notification will not be resent over and over again unless
      # this is set to true.
      @@resend = false
      
      def initialize(recipients, options = {})
        @recipients = recipients
        @from = options[:from] || "opticon@#{ENV['HOSTNAME']}"
      end
      
      def notify(failures)
        failures = [failures] unless failures.kind_of? Array
        
        failures_by_uri = {}
        failures.each do |f|
          failures_by_uri[f.uri] ||= []
          failures_by_uri[f.uri] << f
        end
        
        if ARGV.include?("-v")
          puts "Notifying #{recipients.inspect} about #{failures.size} failures:"
          failures.each{|f| puts "  #{f.failure_message}"}
        end
        
        failures_by_uri.each do |uri, failures|
          Opticon::Mailer.deliver_failure_notification(
            uri,
            failures.collect{|f| f.failure_message}.join("\n"),
            recipients, from
          )
        end
      end
    end
    
    # Prints failures to an output stream. By default failures are sent to 
    # $stderr, but this can be changed using the :output_stream configuration 
    # option.
    class IOStream
      attr_accessor :output_stream
      
      def initialize(output_stream = $stderr, options = {})
        @output_stream = output_stream
      end
      
      def notify(failures)
        if ARGV.include?("-v")
          puts "Printing #{failures.size} failures to #{output_stream}:"
          failures.each{|f| puts "  #{f.failure_message}"}
        end
        
        failures.each do |f|
          # TODO: make output format configurable
          output_stream.puts "#{Time.now} :: #{f.uri} :: #{f.failure_message}"
        end
      end
    end
    
    # Sends failure notifications as SNMP traps.
    #
    # The notification is sent using the `snmptrap` command-line utility, part
    # of the Net-SNMP perl package. You will have to install Net-SNMP prior
    # to using this notifier. On Linux machines this is generally as easy as
    # `apt-get install net-snmp` or `smart install net-snmp`. On Windows
    # machines, you're on your own.
    #
    # In the future the net-snmp requirement may be swapped in favor of using
    # the native Ruby SNMP library, but for now you need net-snmp.
    class SNMPTrap
      attr_accessor :to_host, :snmp_community, :enterprise_oid, 
        :snmp_persistent_dir
      
      def initialize(to_host, snmp_community, options = {})
        @to_host = to_host
        @snmp_community = snmp_community
        @enterprise_oid = options[:enterprise_oid] || '1.3.6.1.4.1.3.1.1'
        @snmp_persistent_dir = options[:snmp_persistent_dir] || '/tmp'
      end
      
      def notify(failures)
        failures = [failures] unless failures.kind_of? Array
        
        if ARGV.include?("-v")
          puts "Sending SNMP trap(s) to #{to_host} regarding #{failures.size} failures:"
          failures.each{|f| puts "  #{f.failure_message}"}
        end
        
        failures.each do |f|
          oid = '1.3.1.2.1.1.0'
          typ = 's'
          
          # TODO: make msg format configurable
          msg = ("Opticon Test Failure on URL #{f.uri} :: #{f.failure_message}").gsub(/"/, '\"')
          
          debug = "-d" if ARGV.include?("-v")
          cmd = %{snmptrap -v 1 #{debug} -c #{snmp_community} #{to_host}  #{enterprise_oid} #{ENV['HOSTNAME']} 6 0 '' #{oid} #{typ} "#{msg}"}
          
          puts ">> #{cmd}" if ARGV.include?("-v")
          
          # Band-aid fix for bug in Net-SNMP.
          # See http://sourceforge.net/tracker/index.php?func=detail&aid=1588455&group_id=12694&atid=112694
          ENV['SNMP_PERSISTENT_DIR'] ||= snmp_persistent_dir
          
          `#{cmd}`
        end
      end
    end
    
    # Dummy notifier used in testing. It doesn't do anything other than store
    # the error_messages fed in to the notify method. These can later be
    # be retrieved by looking at the object's notifications instance attribute.
    class Dummy
      attr_accessor :notifications
    
      def initialize()
        @notifications = []
      end
    
      def notify(failures)
        @notifications << failures
      end
    end
  end
end
