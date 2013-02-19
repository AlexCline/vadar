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

  basedn = "cn=users,dc=corp,dc=vivisimo,dc=com"
  scope = Net::LDAP::SearchScope_WholeSubtree
  filter = "(&(objectClass=person)(!(objectClass=computer))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"
  attrs = ['sAMAccountName','mail','pwdLastSet']

  ldap = Net::LDAP.new
  ldap.host = "corp.vivisimo.com"
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
      next  # These passwords have already expired.
    end

    # Send a notice 14, 7, 3, 2 and 1 days before expiration
    if [14, 7, 3, 2, 1].include? numDays
      acct[:notify] = true
      acct[:pwDays] = numDays
    end

    $accounts.push acct
  end
end

def send_notice acct
  server  = "localhost"
  to      = acct[:mail]
  from    = "BigData Lab IT <im-bigdata-pgh-sysadmins@wwpdl.vnet.ibm.com>"
  cc      = []
  bcc     = "acline@us.ibm.com"
  subject = "Your BigData Lab Active Directory Password is about to expire."
  head    = ""
  body    = ""

  head << "From: #{from}\n"
  head << "To: #{to}\n"
  head << "Subject: #{subject}\n"

  body << <<-eos
#{Time.now.to_s}

Your BigData Lab Active Directory Password will expire in #{acct[:pwDays]} days.

Your user ID is: #{acct[:id]}

Change your password before it expires at:  http://corp.vivisimo.com/PasswordReset.aspx

You will need to be in the PGH office or connected to the PGH VPN to use the link above.

The ITCS104 authentication standard states that a password may not be reused until after at least eight iterations. The ITCS104 standard also mandates a minimum change interval of one day, i.e. one change every 24 hours.

Note: Please direct questions regarding this communication to the BigData IT team or reply to this note.

eos

  Net::SMTP.start(server, 25) do |smtp|
    message = "#{head}\n#{body}\n"
    res = smtp.send_message message, from, to, cc, bcc
    smtp.finish
  end
end


corp_lookup
$accounts.each do |acct|
  if acct[:notify]
    puts "Sending #{acct[:pwDays]} days notice to #{acct[:mail]}"
    send_notice acct
  end
end
