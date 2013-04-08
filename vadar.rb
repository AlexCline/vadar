# encoding 'utf-8'
require 'rubygems'
require 'bundler/setup'
require 'net/ldap'
require 'net/http'
require 'json'
require 'awesome_print'

# Load the file with BIND credentials: BIND_USER & BIND_PASS
env_vars = File.join(Dir.pwd, 'env_vars.rb')
load(env_vars) if File.exists?(env_vars)

action = ARGV[0]
$accounts = []
$verbose  = false
$skipaccounts = ['sp_administrator', 'sp_farm', 'sp_database', 'symantec-nbu']

def corp_lookup
  basedn = "dc=corp,dc=vivisimo,dc=com"
  scope = Net::LDAP::SearchScope_WholeSubtree
  filter = "(&(objectClass=person)(!(objectClass=computer))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"
  attrs = ['displayName','sAMAccountName','dn','mail', 'serialNumber']

  ldap = Net::LDAP.new
  ldap.host = "corp.vivisimo.com"
  ldap.port = "389"
  ldap.auth ENV['BIND_USER'], ENV['BIND_PASS']
  
  ldap.search(:base => basedn, :scope => scope, :filter => filter, :attributes => attrs, :return_result => true) do |entry|
    # Skip accounts for sharepoint until P9
    if $skipaccounts.include? entry.sAMAccountName.first.to_s
      next
    end

    account = { 
      :id   => entry.sAMAccountName.first.to_s, 
      :dn   => entry.dn.to_s,
      :msg  => "",
      :mail => "",
      :sn   => "",
      :pass => false,
    }

    if $verbose 
      account[:msg] += "#{account[:id]}: DN: #{account[:dn]}\n"
    end

    if entry.respond_to? :mail
      account[:mail] = entry.mail.first.to_s
      if $verbose
        account[:msg] += "#{account[:id]}: mail: #{account[:mail]}\n"
      end
    else
      account[:msg]  += "#{account[:id]}: No email address in AD\n"
      account[:needsEmail] = true
      account[:softfail] = true
    end

    if entry.respond_to? :serialNumber
      account[:sn] = entry.serialNumber.first.to_s
      if $verbose
        account[:msg] += "#{account[:id]}: sn: #{account[:sn]}\n"
      end
    else
      account[:msg] += "#{account[:id]}: No serial number in AD\n"
      account[:needsSerialNumber] = true
      account[:softfail] = true
    end

    $accounts.push account
  end
end

def bluepages_lookup
  w3url = "http://bluepages.ibm.com/BpHttpApisv3/slaphapi?"

  $accounts.each do |account|

    if account[:sn] != ""
      account[:msg] += "#{account[:id]}: BluePages lookup with sn: #{account[:sn]}\n"
      uri = URI("#{w3url}ibmperson/serialnumber=#{account[:sn].to_s}.list/byjson")
      json = Net::HTTP.get(uri)
      data = JSON.parse(json)

      if data["search"]["return"]["count"] == 0
        account[:msg] += "#{account[:id]}: No account in BluePages with sn: #{account[:sn]}\n"
        account[:hardfail] = true
        next
      end

      attributes = data["search"]["entry"].first["attribute"]
      attributes.each do |attr|
        if attr["name"] == "mail"
          if !account[:needsEmail] && attr["value"].first != account[:mail]
            account[:msg] += "#{account[:id]}: Mail in BluePages doesn't match Mail in AD [#{attr["value"].first} != #{account[:mail]}]\n"
            account[:updatemail] = true
          elsif attr["value"].first == account[:mail]
            account[:msg] += "#{account[:id]}: Account in AD is valid\n"
            account[:pass] = true
          elsif account[:needsEmail]
            account[:mail] = attr["value"].first
            account[:msg] += "#{account[:id]}: Will update SN in AD to #{account[:mail]}\n"
          end
        end
      end

      next
    end

    if account[:mail] != ""
      account[:msg] += "#{account[:id]}: BluePages lookup with mail: #{account[:mail]}\n"
      uri = URI("#{w3url}ibmperson/mail=#{account[:mail].to_s}.list/byjson")
      json = Net::HTTP.get(uri)
      data = JSON.parse(json)

      if data["search"]["return"]["count"] == 0
        if account[:needsSerialNumber]
          account[:msg] += "#{account[:id]}: Please manually check BluePages to see if this user has changed their primary internet address.\n"
        end
        account[:msg] += "#{account[:id]}: No account in BluePages with mail: #{account[:mail]}\n"
        account[:hardfail] = true
        next
      end

      attributes = data["search"]["entry"].first["attribute"]
      attributes.each do |attr|
        if attr["name"] == "serialnumber"
          if !account[:needsSerialNumber] && attr["value"].first != account[:sn]
            account[:msg] += "#{account[:id]}: SN in BluePages doesn't match SN in AD [#{attr["value"].first} != #{account[:sn]}]\n"
            account[:updatesn] = true
          elsif attr["value"].first == account[:sn]
            account[:msg] += "#{account[:id]}: Account in AD is valid\n"
            account[:pass] = true
          elsif account[:needsSerialNumber]
            account[:sn] = attr["value"].first
            account[:msg] += "#{account[:id]}: Will update SN in AD to #{account[:sn]}\n"
          end
        end
      end
    end

    if account[:mail] == "" && account[:sn] == ""
      account[:hardfail] = true
      account[:msg] += "#{account[:id]}: Account has no email or SN.  Failing.\n"
    end

  end
end

def corp_save
  ldap = Net::LDAP.new
  ldap.host = "corp.vivisimo.com"
  ldap.port = "389"
  ldap.auth ENV['BIND_USER'], ENV['BIND_PASS']


  $accounts.each do |account|
    ops = []

    if account[:hardfail]
      account[:msg] += "#{account[:id]}: Encountered hardfail, aborting AD update."
      next
    end

    if account[:needsSerialNumber]
      ops.push [:replace, :serialNumber, account[:sn]]
      account[:msg] += "#{account[:id]}: Updating SN in AD to #{account[:sn]}\n"
    end

    if account[:needsEmail]
      ops.push [:replace, :mail, account[:mail]]
      account[:msg] += "#{account[:id]}: Updating mail in AD to #{account[:mail]}\n"
    end

    if account[:needsSerialNumber] || account[:needsEmail]
      result = ldap.modify :dn => account[:dn], :operations => ops
      if result == true
        account[:msg] += "#{account[:id]}: AD update successful\n"
        account[:pass] = true
      else
        account[:msg] += "#{account[:id]}: AD update unsuccessful: #{result.inspect}\n"
      end
      # Not actually a failure, but will cause the account audit to be printed.
      account[:softfail] = true
    end
  end
end

def send_mail verbose, tagline
  failures = false
  server  = "localhost"
  to      = "im-bigdata-pgh-sysadmins@wwpdl.vnet.ibm.com"
  from    = "VADAR <acline@us.ibm.com>"
  subject = "Vigilant Active Directory Auditor Results"
  head    = ""
  body    = ""
  details = ""

  head << "From: #{from}\n"
  head << "To: #{to}\n"
  head << "Subject: #{subject}\n"

  body << "#{tagline}  Please review the data below and take necessary steps.\n\n"

  $accounts.each do |account|
    if verbose
      body << "#{account[:msg]}\n"
    end

    if account[:hardfail]
      failures = true
      body << "A problem was detected with account: #{account[:id]}\n"
      body << "  #{account[:msg].split(/\r?\n/).last}\n\n"
      details << "#{account[:msg]}\n\n"
    end

    if account[:softfail]
      details << "An information update was processed for account: #{account[:id]}\n"
      details << "  #{account[:msg].split(/\r?\n/).join("\n  ")}\n\n"
    end

  end

  if !failures
    body << "There were no account issues detected this run."
  end

  if details != ""
    body << "\n\nDetails:\n\n#{details}"
  end

  if $verbose
    body << "\n\n** The following UserIDs were verified against BluePages **\n\n"
    $accounts.each do |account|
      if account[:pass]
        body << "#{account[:id]}:x:1:1:#{account[:mail]};#{account[:sn]}::AD\n"
      end
    end
  end

#  Net::SMTP.start(server, 25) do |smtp|
  message = "#{head}\n#{body}\n"
#    res = smtp.send_message message, from, to
#    smtp.finish
#  end

  puts message
end


if action == "daily_audit"
  corp_lookup
  bluepages_lookup
  corp_save
  send_mail false, "Daily Account Audit:"
elsif action == "quarterly_report"
  $verbose = true
  corp_lookup
  bluepages_lookup
  send_mail false, "Quarterly Employment Verification:"
elsif action == "test"
  $verbose = true
  corp_lookup
  bluepages_lookup
  corp_save
  
  $accounts.each do |account|
    ap account.inspect
  end
end
