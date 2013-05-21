# Vadar.rb
# The VADAR class
require 'configuration'
require 'logging'
require 'controllers/ad_controller'
require 'controllers/person_controller'

class Vadar
  include Logging
  attr_writer :configuration
  
  def configuration
    @configuration ||= Configuration.new
  end

  def initialize
  	@ad = AdController.new
    @people = []
  end

  def lookupAccounts
  	accts = @ad.getAllAccounts
    accts.each do |acct|
      if configuration.config["ignored_users"].include? acct["sAMAccountName"]
        next
      end

      @people << PersonController.new(acct["sAMAccountName"], acct["distinguishedName"], 
        acct["serialNumber"], acct["department"], acct["mail"])
    end
  	@people
  end

  def syncAllAccounts verbose=false
    result = []
    #@people << PersonController.new("cline", nil, nil, nil, nil)
    result << "Looking up all accounts." if verbose
    lookupAccounts
    @people.each do |person|
      result << "#{person.id}: Syncing account." if verbose
      sync = person.sync
      result << "#{person.id}: Account looks ok." if verbose and person.log.size == 0
      result << person.log.map{|l| "#{person.id}: #{l}"} if sync == false or verbose
    end
    result
  end

end

#@vadar = Vadar.new
#@vadar.run(ARG[0]})