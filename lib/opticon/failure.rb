module Opticon
  module Failure
    class Base
      attr_reader :uri, :condition, :response
      attr_accessor :exception
    
      def initialize(uri, condition, response)
        @uri = uri
        @condition = condition
        @response = response
      end
      
      def to_s
        "#<#{self.class} [#{uri}] #{failure_message}>"
      end
    end
    
    class ConnectionFailure < Base
      def failure_message
        "#{exception.message} (#{exception.class})"
      end
    end
    
    class ResponseCodeTestFailure < Base
      def failure_message
        "The service did not respond as expected; expected response code was #{condition.inspect} but got #{response.code.inspect} (#{response.message.inspect})"
      end
    end
    
    class ContentTestFailure < Base
      def failure_message
        if exception 
          return exception.message
        else
          "Page content did not include the expected #{condition.class} #{condition.inspect}"
        end
      end
    end

    class NotContentTestFailure < Base
      def failure_message
        if exception 
          return exception.message
        else
          "Page content include the unexpected #{condition.class} #{condition.inspect}"
        end
      end
    end
  end
end
