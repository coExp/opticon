require 'net/http'
require 'net/https'
require 'uri'
require 'timeout'

module Opticon
  module HTTP
    def response
      raise "URI cannot be empty" if uri.kind_of? String and (uri.nil? or uri.empty?)
      
      self.uri = URI.parse(self.uri) unless self.uri.kind_of? URI
      if @response and self.uri == @last_fetched_uri
        @response
      else 
        @response = get(self.uri)
      end
    end
    
    def get(get_uri)
      if self.uri.kind_of? URI
        get_uri = self.uri
      else
        get_uri = URI.parse(self.uri) unless self.uri.kind_of? URI
      end
      
      @last_fetched_uri = get_uri
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      
      response = nil

      timeout(Opticon.default_timeout) do
        http.start do
          path = uri.path.empty? ? '/' : uri.path
          response = http.request_get(path)
        end
      end

      response
    end
  end
end