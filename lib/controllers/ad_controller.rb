require 'logging'
require 'models/ad'

class AdController
  include Logging

  def initialize
    @ad = Ad.new
  end

  def setManager id, mgrsn, mgrmail
    sn = @ad.modify id, [:departmentNumber, mgrsn]
    mail = @ad.modify id, [:department, mgrmail]
    return sn && mail
  end

  def setMail id, mail
    return @ad.modify id, [:mail, mail]
  end

  def setSerial id, serial
    return @ad.modify id, [:serialNumber, serial]
  end

  def getDN id
    return @ad.search id, :dn
  end

  def getManagerSerial id
    return @ad.search id, :departmentNumber
  end

  def getManagerMail id
    return @ad.search id, :department
  end

  def getMail id
    return @ad.search id, :mail
  end

  def getSerial id
    return @ad.search id, :serialNumber
  end

  def getId dn
    return @ad.search dn, :sAMAccountName, "distinguishedName"
  end

  def getIdFromSerial sn
    return @ad.search sn, 'sAMAccountName', 'serialNumber'
  end

  def getAllAccounts
    return @ad.getAllAccounts
  end

end