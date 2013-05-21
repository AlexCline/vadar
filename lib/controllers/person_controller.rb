# Person.rb
require 'controllers/ad_controller'
require 'controllers/bp_controller'
require 'logging'

class PersonController
  include Logging
  attr_accessor :id, :dn, :sn, :mail, :mgrmail, :mgrsn

  def initialize id, dn=nil, sn=nil, mgrmail=nil, mail=nil, mgrsn=nil
    @id = id
    @dn = dn
    @sn = sn
    @mgrmail = mgrmail
    @mgrsn = mgrsn
    @mail = mail
    @log = []

    @ad = AdController.new
    @bp = BpController.new
  end

  def log
    @log
  end

  def sync
    sn = syncSerial
    mail = syncMail
    mgr = syncManager
    raise "User doesn't exist in BP with #{@sn} or #{@mail}.  Aborting" if (!sn and !mail and !mgr)
    return (sn and mail and mgr)
  end

  def getSerial
    syncSerial if @sn.nil?
    @sn
  end

  def getMail
    syncMail if @mail.nil?
    @mail
  end

  def getManagerMail
    syncManager if @mgrmail.nil?
    @mgrmail
  end

  def getManagerSerial
    syncManager if @mgrsn.nil?
    @mgrsn
  end

  def loadFromAD
    # get the current serial and mail from AD
    @sn   = @ad.getSerial(@id)
    @mail = @ad.getMail(@id)
    @mgrsn  = @ad.getManagerSerial(@id)
    @mgrmail = @ad.getManagerMail(@id)

    # if the serial and mail are not set in AD, return an error
    if @sn.nil? and @mail.nil?
      return logMessage "The account is missing both the email and serial number in AD.  Aborting."
    end
  end

  def syncSerial
    loadFromAD

    return logMessage "There is no serial in AD, cannot lookup mail in BP." if @mail.nil?

    # use the mail to lookup the serial in BP
    # if the serial in bp is different than the one in AD, save to AD
    begin
      bpsn = @bp.getSerial(@mail)
    rescue
      return logMessage "There is no account in BP with the mail #{@mail}."
    end

    if bpsn != @sn
      @log << "Setting the sn in AD to #{bpsn}."
      @sn = bpsn
      return @ad.setSerial(@id, bpsn)
    else
      @log << "The serial number in AD matches BP."
      return true
    end
  end

  def logMessage msg
    @log << msg
    logger.error msg
    return false
  end

  def syncMail
    loadFromAD

    return logMessage "There is no serial in AD, cannot lookup mail in BP." if @sn.nil?

    # use the serial to lookup the mail in BP
    # if the mail in bp is different than the one in AD, save to AD
    begin
      bpmail = @bp.getMail(@sn)
    rescue
      return logMessage "There is no account in BP with the serial #{@sn}."
    end

    if bpmail != @mail
      @log << "Setting the mail in AD to #{bpmail}."
      @mail = bpmail
      return @ad.setMail(@id, bpmail)
    else
      @log << "The mail in AD matches BP."
      return true
    end
  end

  def syncManager
    loadFromAD

    begin
      bpmgrmail = @bp.getManagerMail(@sn)
      bpmgrsn = @bp.getManagerSerial(@sn)
    rescue
      return logMessage "There is no manager info in BP for serial #{@sn}."
    end

    if @mgrsn != bpmgrsn or @mgrmail != bpmgrmail
      logMessage "Mgr in AD and BP don't match.  Setting AD to #{bpmgrsn}, #{bpmgrmail}"
      @mgrsn = bpmgrsn
      @mgrmail = bpmgrmail
      return @ad.setManager(@id, bpmgrsn, bpmgrmail)
    else
      return true
    end
  end
end