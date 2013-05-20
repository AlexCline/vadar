require 'net/http'
require 'json'

class Bp
  attr_writer :configuration, :bp
  
  def configuration
    @configuration ||= Configuration.new
  end

  def initialize
    env_vars = File.join(Dir.pwd, 'config/env_vars.rb')
    load(env_vars) if File.exists?(env_vars)
    @url = ENV['BP_URL']
  end

  def connected?
    begin
      uri = URI.parse(@url)
      res = Net::HTTP.get(uri)
    rescue
      raise "Error connecting to BP server. #{uri}"
    end
  end

  def getManagerSerial serial
    connected?
    result = search("serialnumber", serial)
    raise "Unable to find a manager for the serial: #{serial}" if result.nil?
    mgrserial = getAttr("manager", result).split(',')[0].split('=')[1]
  end

  def getManagerMail serial
    getMail(getManagerSerial(serial))
  end

  def getMail serial
    connected?
    result = search("serialnumber", serial)
    raise "Unable to find an email for the serial: #{serial}" if result.nil?
    return getAttr("mail", result)
  end

  def getSerial mail
    connected?
    result = search("mail", mail)
    raise "Unable to find a serial for the mail: #{serial}" if result.nil?
    return getAttr("serialnumber", result)
  end

  private

  def getAttr(needle, haystack)
    result = nil
    attrs = haystack.first["attribute"]
    attrs.each do |attr|
      attr["name"] == needle ? result = attr["value"].first : next
    end
    result
  end

  def search(field, value)
    uri = URI("#{@url}/#{field}=#{value}.list/byjson")
    data = JSON.parse(Net::HTTP.get(uri))

    return (data["search"]["return"]["count"] == 0) ?
      nil : data["search"]["entry"]
  end
end