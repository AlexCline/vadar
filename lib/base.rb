require 'logging'

class Base
	include Logging
	Logging.output = File.expand_path('../../log/development.log', __FILE__)
end