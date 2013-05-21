require 'models/bp'
require 'logging'

class BpController
  include Logging
  def initialize
    @bp = Bp.new
  end

  def getManagerSerial serial
    result = @bp.search("serialnumber", serial)
    raise "Unable to find a manager for the serial: #{serial}" if result.nil?
    mgrserial = @bp.getAttr("manager", result).split(',')[0].split('=')[1]
  end

  def getManagerMail serial
    getMail(getManagerSerial(serial))
  end

  def getMail serial
    result = @bp.search("serialnumber", serial)
    raise "Unable to find an email for the serial: #{serial}" if result.nil?
    return @bp.getAttr("mail", result)
  end

  def getSerial mail
    result = @bp.search("mail", mail)
    raise "Unable to find a serial for the mail: #{mail}" if result.nil?
    return @bp.getAttr("serialnumber", result)
  end

end