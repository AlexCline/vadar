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

  def getManager id
    options = @options.merge({:filter => userFilter(id), :attributes => ['manager']})
    @ldap.search(options) do |entry|
      return entry.respond_to?(:manager) ? entry.manager.first.to_s : nil
    end
  end

  def getMail id
    options = @options.merge({:filter => userFilter(id), :attributes => ['mail']})
    @ldap.search(options) do |entry|
      return entry.respond_to?(:mail) ? entry.mail.first.to_s : nil
    end
    raise "#{id}: Couldn't find user with the requested id"
  end

  def getSerial id
    options = @options.merge({:filter => userFilter(id), :attributes => ['serialNumber']})
    @ldap.search(options) do |entry|
      return entry.respond_to?(:serialNumber) ? entry.serialNumber.first.to_s : nil
    end
    raise "#{id}: Couldn't find user with the requested id"
  end

  def userFilter sAMAccountName
    configuration.config['ad']['filter'].insert(-2,
      "(sAMAccountName=#{sAMAccountName})")
  end

end