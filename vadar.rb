# encoding 'utf-8'
require 'rubygems'
require 'bundler/setup'
require 'net/ldap'
require 'net/http'
require 'json'

# Load the file with BIND credentials: BIND_USER & BIND_PASS
env_vars = File.join(Dir.pwd, 'env_vars.rb')
load(env_vars) if File.exists?(env_vars)

host = "corp.vivisimo.com"
port = "389"
basedn = "dc=corp,dc=vivisimo,dc=com"
w3url = "http://bluepages.ibm.com/BpHttpApisv3/slaphapi?"

scope = Net::LDAP::SearchScope_WholeSubtree
filter = "(&(objectClass=person)(!(objectClass=computer))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"
attrs = ['displayName','sAMAccountName','dn','mail']


ldap = Net::LDAP.new
ldap.host = host
ldap.port = port
ldap.auth ENV['BIND_USER'], ENV['BIND_PASS']

ldap.search(:base => basedn, :scope => scope, :filter => filter, :attributes => attrs, :return_result => true) do |entry|

  if entry.respond_to? :mail
    uri = URI("#{w3url}ibmperson/mail=#{entry.mail.first}.list/byjson")
    json = Net::HTTP.get(uri)
    data = JSON.parse(json)

    if data["search"]["return"]["count"] == 0
      puts "No active account in BluePages for email #{entry.mail.first.to_s} for user #{entry.dn.to_s}"
    end

    if data["search"]["return"]["count"] > 1
      puts "More than one result in BluePages for #{entry.mail.first.to_s}"
    end

    #data["search"]["entry"][0]["attribute"].each { |attr| attr["name"] == "ibmserialnumber" ? (puts attr["value"]) : nil }
  else

    puts "No Email address in AD for #{entry.dn.to_s}"
  end


end