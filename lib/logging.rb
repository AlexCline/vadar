require 'logger'

module Logging
  def logger
    @logger ||= Logging.logger_for(self.class.name)
  end

  # Use a hash class-ivar to cache a unique Logger per class:
  @loggers = {}

  class << self
    def output
      @out ||= STDERR
    end
    def output= path_or_stream
      if @out.nil?
        @out = path_or_stream
      else
        raise "You can't change the output once a logger is used. Used by #{@loggers.keys.join(', ')}"
      end
    end

    def logger_for(classname)
      @loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      Logger.new(output).tap do |logger|
        logger.progname = classname
      end
    end
  end
end