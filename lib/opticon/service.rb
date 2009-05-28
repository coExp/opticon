require 'uri'
require File.dirname(File.expand_path(__FILE__))+'/tester'

module Opticon
  class Service
    attr_accessor :notifiers
  
    def initialize(uri, notifiers = Opticon.default_notifiers)
      raise ArgumentError, "You must either provide a valid Notifier or set Opticon.default_notifiers." unless
        notifiers and (notifiers.respond_to? :notify or notifiers.first.respond_to? :notify)
      @uri = URI.parse(uri)
      
      if notifiers.kind_of? Array
        @notifiers = notifiers
      else
        @notifiers = [notifiers]
      end
    end
    
    def to_s
      @uri.to_s
    end
    
    def test(*args, &block)
      if block
        @prev_batch_notify = @batch_notify
        @batch_notify = true
        instance_eval(&block)
        send_batch_notification
        @batch_notify = @prev_batch_notify
      else
        tester_type = args[0]
        condition = args[1]
        options = args[2]
   
        # If asked, modify timeout for this test
        if args.size == 3 and args[2].class == Fixnum then 
          tmp_timeout = Opticon::default_timeout           
          Opticon::default_timeout= args[2]                
        end  
 
        case tester_type
        when :responds_with_code, 'responds_with_code'
          tester = Opticon::Tester::ResponseCodeTester.new
        when :response_body_contains, 'response_body_contains'
          tester = Opticon::Tester::ContentTester.new
        when :response_body_not_contains, 'response_body_not_contains'
          tester = Opticon::Tester::NotContentTester.new
        when Class
          tester = tester.new
        when Tester::Base
          tester = tester
        else
          begin
            tester_class = "Opitcon::Tester::#{tester.to_s}".constantize
            tester = tester_class.new
          rescue NameError
            bad_tester = true
          end
          
          if bad_tester or !tester.respond_to? :test
            raise ArgumentError, "'#{tester}' is not a valid tester. The parameter must be: 'responds_with_code', 'response_body_contains', or"+
              " an Object or Class that responds to a 'test' method."
          end
        end
        
        tester.uri = @uri
        
        @failures ||= []
        
        debug = "#{@uri} #{tester_type} #{condition.inspect}?"
        
        if tester.run(condition)
          puts "#{debug} ==> PASSED!" if ARGV.include?("-v")
        else
          puts "#{debug} ==> FAILED!" if ARGV.include?("-v")
          notifiers.each {|n| n.notify(tester.failure)} unless @batch_notify
          @failures << tester.failure
        end

        # Put the timeout to default value
        if tmp_timeout != nil then Opticon::default_timeout= tmp_timeout end
 
        # return self to allow for chaining test calls
        return self
      end
    end
    
    def send_batch_notification
      notifiers.each {|n| n.notify(@failures)} unless @failures.empty?
    end
  
    def failures?
      if @failures.nil?
        raise "Test has not yet been run."
      else
        not @failures.empty?
      end
    end
  end
end

# this makes it possible to use Strings like Service objects
class String
  def method_missing(method, *args, &block)
    service.send(method, *args, &block)
  end
  
  private
  def service
    @service ||= Opticon::Service.new(to_s)
  end
end
