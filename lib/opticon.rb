$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Opticon

  @@default_notifiers = []
  def default_notifiers
    @@default_notifiers
  end
  def default_notifiers=(notifiers)
    notifiers = [notifiers] unless notifiers.kind_of? Array
    @@default_notifiers = notifiers
  end
  module_function :default_notifiers, 'default_notifiers='
  
  @@default_timeout = 3
  def default_timeout
    @@default_timeout
  end
  def default_timeout=(timeout)
    @@default_timeout = timeout
  end
  module_function :default_timeout, 'default_timeout='
  
end

require File.dirname(File.expand_path(__FILE__))+'/opticon/service'
require File.dirname(File.expand_path(__FILE__))+'/opticon/notifier'