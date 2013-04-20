# encoding 'utf-8'
require 'rubygems'
require 'bundler/setup'
require 'net/ldap'
require 'net/smtp'
require 'awesome_print'

# Load the file with BIND credentials: BIND_USER & BIND_PASS
env_vars = File.join(Dir.pwd, 'env_vars.rb')
load(env_vars) if File.exists?(env_vars)

$accounts = []
$maxPwAge = 7776000  # 90 days in seconds

def corp_lookup

  basedn = "cn=users,dc=bigdatalab,dc=ibm,dc=com"
  scope = Net::LDAP::SearchScope_WholeSubtree
  filter = "(&(objectClass=person)(!(objectClass=computer))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"
  attrs = ['sAMAccountName','mail','pwdLastSet']

  ldap = Net::LDAP.new
  ldap.host = "dc-0.bigdatalab.ibm.com"
  ldap.port = "389"
  ldap.auth ENV['BIND_USER'], ENV['BIND_PASS']

  if !ldap.bind
    puts "Problem with AD connection.  Aborting!"
  end
 
  ldap.search(:base => basedn, :scope => scope, :filter => filter, :attributes => attrs, :return_result => true) do |entry|

    acct = { 
      :id     => entry.sAMAccountName.first.to_s, 
      :mail   => entry.mail.first.to_s,
      :pwdays => 0,
      :notify => false,
    }

    # Calculate the epoch time from windows time and get a number of days till expiration
    unix_time = (entry.pwdLastSet.first.to_i)/10000000-11644473600
    numDays = (unix_time + $maxPwAge - Time.now.to_i)/86400

    if numDays < 0
      acct[:pwdays] = numDays
      $accounts.push acct
    end

  end
end

corp_lookup
$accounts.sort_by { |acct| acct[:id] }.each do |acct|
  puts "#{acct[:id]} expired #{acct[:pwdays]} ago."
end
