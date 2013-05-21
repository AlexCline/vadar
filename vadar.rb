#! /usr/bin/env ruby
$:.unshift(File.expand_path('../lib/', __FILE__))

require 'rubygems'
require 'logging'
require 'vadar'

Logging.output = File.expand_path('../log/production.log', __FILE__)

v = Vadar.new
case ARGV[0]
when "daily_audit"
  puts v.syncAllAccounts
when "quarterly_report"
  puts v.syncAllAccounts true
else
  puts v.syncAllAccounts
end
