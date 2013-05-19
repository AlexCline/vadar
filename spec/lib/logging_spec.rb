require 'spec_helper'
require 'logging'

describe Logging do

  class TestClass
    include Logging

    def trigger msg
      logger.warn(msg)
      logger.info(msg)
    end
  end

  describe ".logger" do
    it "works" do
      TestClass.new.trigger "hello"
    end
  end
end