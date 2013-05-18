# AdLookup
require 'net/ldap'
require 'configuration'

class Ad
  attr_writer :configuration, :ldap
  
  def configuration
    @configuration ||= Configuration.new
  end

  def initialize
    @ldap = Net::LDAP.new
    @ldap.host = configuration.config['ad']['host']
    @ldap.port = configuration.config['ad']['port']
    @ldap.auth ENV['BIND_USER'], ENV['BIND_PASS']
    @options = {:base => configuration.config['ad']['basedn']}
  end

  def connected?
    unless @ldap.bind
      raise "Error connecting to AD server. \
#{@ldap.get_operation_result.code}: \
#{@ldap.get_operation_result.message}"
    end
  end

  def setManager id, manager
    return modify(getDN(id), [:manager, getDN(manager)])
  end

  def setMail id, mail
    return modify(getDN(id), [:mail, mail])
  end

  def setSerial id, serial
    return modify(getDN(id), [:serialNumber, serial])
  end

  def getDN id
    return search id, :dn
  end

  def getManager id
    dn = search id, :manager
  end

  def getMail id
    return search id, :mail
  end

  def getSerial id
    return search id, :serialNumber
  end

  def getId dn
    return search dn, :sAMAccountName, "dn"
  end

  def modify dn, opts
    connected?
    result = @ldap.modify(:dn => dn, :operations => [[:replace].concat(opts)])
    raise "Error modifying #{opts} of #{dn}. \
#{@ldap.get_operation_result.code}: \
#{@ldap.get_operation_result.message}" if result != true
    return result
  end

  def search id, obj, field="sAMAccountName"
    opts = @options.merge({:filter => makeFilter(id, field), :attributes => [obj.to_s]})
    connected?
    @ldap.search(opts) do |entry|
      return entry.respond_to?(obj) ? entry[obj].first.to_s : nil
    end
    raise "Couldn't find user with id #{id} using #{opts}"
  end

  def makeFilter id, field
    configuration.config['ad']['filter'].sub("VALUE", id).sub("FIELD", field)
  end

end