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

  def getManager serial
    result = search("serialnumber", serial)
    result.nil? ? return : mgrserial = getAttr("manager", result).split(',')[0].split('=')[1]
    getMail(mgrserial)
  end

  def getMail serial
    result = search("serialnumber", serial)
    return result.nil? ? nil : getAttr("mail", result)
  end

  def getSerial mail
    result = search("mail", mail)
    return result.nil? ? nil : getAttr("serialnumber", result)
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