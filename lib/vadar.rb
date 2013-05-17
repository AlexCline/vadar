# Vadar.rb
# The VADAR class
require 'configuration'

class Vadar
  attr_writer :configuration
  
  def configuration
    @configuration ||= Configuration.new
  end

end