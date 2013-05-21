dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'logging'

# Set the logging to the test log.
Logging.output = File.expand_path('../../log/test.log', __FILE__)
