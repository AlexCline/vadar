# Person.rb
require 'ad'
require 'bp'
require 'base'

class Person < Base
  attr_accessor :id, :dn, :sn, :mail, :mgr

  def initialize id, dn, sn, mgr, mail
    @id = id
    @dn = dn
    @sn = sn
    @mgr = mgr
    @mail = mail

    @ad = Ad.new
    @bp = Bp.new
    logger.debug "Creating person #{id}"
  end

  def getSerial
    # get the serial from AD
    @sn ||= @ad.getSerial(@id)
    # if no ad serial, get the mail from ad
    if @sn.nil?
      @mail ||= @ad.getMail(@id)
      # if no mail in ad, raise an error
      raise "#{@id}: User doesn't have a serial number or email in AD." if @mail.nil?
      # use the ad mail to get the bp serial
      @sn = @bp.getSerial(@mail)
    end
  end

  def getMail
    # get the mail from AD
    @mail ||= @ad.getMail(@id)
    # if no ad mail, get the serial from AD
    if @mail.nil?
      @sn ||= @ad.getSerial(@id)
      # if no serial in AD, raise an error
      raise "#{@id}: User doesn't have a serial number or email in AD." if @sn.nil?
      # use the AD sn to get the BP mail
      @mail = @bp.getMail(@sn)
    end
  end

  def getManager
    @mgr ||= @ad.getManager(@id)
    if @mgr.nil?
      getSerial if @sn.nil?
      @mgr = @bp.getManager(@sn)
      raise "#{@id}: Unable to find manager in AD or BP." if @mgr.nil?
    end
  end

  def syncSerial
    adsn = @ad.getSerial(@id)
    getMail if @mail.nil?
    bpsn = @bp.getSerial(@mail)

    if adsn != bpsn
      @ad.setSerial(@id, bpsn)
    else
      return true
    end
  end

  def syncMail
    admail = @ad.getMail(@id)
    getSerial if @sn.nil?
    bpmail = @bp.getMail(@sn)

    if admail != bpmail
      @ad.setMail(@id, bpmail)
    else
      return true
    end
  end

  def syncManager
    
  end
end