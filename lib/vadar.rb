# Vadar.rb
# The VADAR class
require 'configuration'
require 'base'
require 'ad'
require 'person'

class Vadar < Base
  attr_writer :configuration
  
  def configuration
    @configuration ||= Configuration.new
  end

  def initialize
  	@ad = Ad.new
  end

  def lookupAccounts
  	accts = @ad.getAllAccounts
  	#puts accts
  	accts
  end

end

#@vadar = Vadar.new
#@vadar.run(ARG[0]})