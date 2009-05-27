require File.dirname(File.expand_path(__FILE__))+'/http'
require File.dirname(File.expand_path(__FILE__))+'/failure'

module Opticon
  module Tester
    class Base
      attr_accessor :uri
      attr_reader :failure
      
      include Opticon::HTTP
      
      # Wrapper for calling the test method. 
      # Call this instead of invoking test directly.
      def run(condition)
        begin
          test(condition)
        rescue SocketError, TimeoutError, Net::HTTPError, 
          Errno::ECONNREFUSED, Timeout::Error => e
          @failure = Opticon::Failure::ConnectionFailure.new(uri, condition, nil)
          @failure.exception = $!
          false
        end
      end
    end
    
    # Tests that the service responds with some given HTTP status code.
    class ResponseCodeTester < Base
      protected
      def test(condition)
        case condition
        when :ok
          responds_with_code(200)
        when :success
          responds_with_success
        when :failure, :error
          responds_with_error
        when :redirect
          responds_with_redirect
        when :client_error, :bad_request
          responds_with_client_error
        when :server_error
          responds_with_server_error
        when Integer, Array, Range
          # TODO: if array, assert that each element is an integer (an HTTP response code)
          responds_with_code(condition)
        when String, Regexp
          response_contains(condition)
        else
          raise ArgumentError, "'#{condition.inspect}' is not a valid argument for responds_with"
        end
      end
      
      private
      def responds_with_code(codes)
        r = self.response

        if codes.kind_of? Integer
          result = codes == r.code.to_i
        else
          result = codes.include? r.code.to_i
        end
        
        @failure = Opticon::Failure::ResponseCodeTestFailure.new(uri, codes, r) unless result
        return result
      end
      
      def responds_with_success
        responds_with_code(200..206)
      end
      
      def responds_with_redirect
        responds_with_code(300..207)
      end
      
      def responds_with_client_error
        responds_with_code(400..417)
      end
      
      def responds_with_server_error
        responds_with_code(500..505)
      end
      
      def responds_with_error
        responds_with_client_error or responds_with_client_error
      end
    end
    
    # Tests that the service responds with content that matches some given 
    # string or regular expression.
    class ContentTester < Base
      protected
      def test(condition)
         r = self.response
        
        unless (200..206).include?(r.code.to_i)
          @failure = Opticon::Failure::ContentTestFailure.new(uri, condition, r)
          if (300..307).include?(r.code.to_i)
            @failure.exception = RuntimeError.new("Request was redirected to #{r['location']}.")
          else
            @failure.exception = RuntimeError.new("Request returned code '#{r.message}'"+
              " (#{response.code}) but response must be a 2xx HTTP status code.")
          end
          return false
        end
        
        unless r.class.body_permitted?
          @failure = Opticon::Failure::ContentTestFailure.new(uri, condition, r)
          @failure.exception = RuntimeError.new("Response did not include a body (HTTP response: #{r.inspect})")
          return false
        end
      
        case condition
        when Regexp
          result = condition =~ r.body
        when String
          result = r.body.include? condition
        end
        
        if result
          @failure = nil
        else
          @failure = Opticon::Failure::ContentTestFailure.new(uri, condition, r)
        end
        
        result
      end
    end

    # NOT 
    # Tests that the service responds with content that matches some given 
    # string or regular expression.
    class NotContentTester < Base
      protected
      def test(condition)
         r = self.response
        
        unless (200..206).include?(r.code.to_i)
          @failure = Opticon::Failure::NotContentTestFailure.new(uri, condition, r)
          if (300..307).include?(r.code.to_i)
            @failure.exception = RuntimeError.new("Request was redirected to #{r['location']}.")
          else
            @failure.exception = RuntimeError.new("Request returned code '#{r.message}'"+
              " (#{response.code}) but response must be a 2xx HTTP status code.")
          end
          return false
        end
        
        unless r.class.body_permitted?
          @failure = Opticon::Failure::NotContentTestFailure.new(uri, condition, r)
          @failure.exception = RuntimeError.new("Response did not include a body (HTTP response: #{r.inspect})")
          return false
        end
      
        case condition
        when Regexp
          result = condition =~ r.body
        when String
          result = r.body.include? condition
        end
        
        if result
          @failure = Opticon::Failure::NotContentTestFailure.new(uri, condition, r)
        else
          @failure = nil
        end
        
        if result
	  return false		# Test falled
	else
	  return true		# Test succed
	end
      end
    end

  end
end
