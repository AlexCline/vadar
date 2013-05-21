require 'net/http'
require 'json'
require 'logging'

class Bp
  include Logging
  attr_reader :configuration, :url
  
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
      return false
    end
    return true
  end

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