# Person.rb
require 'ad'
require 'bp'

class Person
  attr_accessor :id, :dn, :msg, :mail, :sn, :mgr

  def initialize id
    @id = id
    @ad = Ad.new
    @bp = Bp.new
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
    @mgr = @ad.getManager(@id)
    getSerial if @sn.nil?
    @mgr = @bp.getManager(@sn)
    raise "#{@id}: Unable to find manager in AD or BP." if @mgr.nil?
  end

  def syncSerial
    # get serial from bp
    # get serial from ad
    # if ad != bp update ad
    # if no serial in ad or bp raise error
  end

  def syncMail

  end

  def syncManager

  end
end