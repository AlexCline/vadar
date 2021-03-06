require 'net/ldap'
require 'configuration'
require 'logging'

class Ad
  include Logging
  attr_writer :configuration, :ldap
  
  def configuration
    @configuration ||= Configuration.new
  end

  def initialize
    @ldap = Net::LDAP.new
    @ldap.host = configuration.config['ad']['host']
    @ldap.port = configuration.config['ad']['port']
    @ldap.auth ENV['BIND_USER'], ENV['BIND_PASS']
    @options = {:base => configuration.config['ad']['basedn'],
                :return_result => false}
    @filter = configuration.config['ad']['filter']
    @attributes = configuration.config['ad']['attributes']
  end

  def connected?
    unless @ldap.bind
      msg = "Error connecting to AD server. \
#{@ldap.get_operation_result.code}: \
#{@ldap.get_operation_result.message}"
      logger.debug msg
      raise msg
    end
    true
  end

  def getAllAccounts
    users = []
    opts = @options.merge({:filter => @filter.clone, 
                           :attributes => @attributes})
    connected?
    logger.info "Getting all user accounts."
    @ldap.search(opts) do |entry|
      id = entry.sAMAccountName.first.to_s
      if !configuration.config['ignored_users'].include? id
        hash = {}
        @attributes.each do |attr|
          if entry.respond_to? attr.to_sym
            hash[attr] = entry[attr].first.to_s
          end
        end
        users << hash
      end
    end
    logger.info "Got #{users.size} accounts."
    raise "Got 0 accounts" if users.size == 0
    users
  end

  def modify id, opts
    dn = search id, :dn
    connected?
    logger.debug "Modifying #{dn} with #{opts}"
    result = @ldap.modify(:dn => dn, :operations => [[:replace].concat(opts)])
    msg = "Error modifying #{opts} of #{dn}. \
#{@ldap.get_operation_result.code}: \
#{@ldap.get_operation_result.message}"
    logger.debug msg if result != true
    raise msg if result != true
    return result
  end

  def search id, obj, field="sAMAccountName"
    opts = @options.merge({:filter => modFilter(id, field), 
                           :attributes => [obj.to_s]})
    connected?
    logger.debug "Searching for #{obj.to_s} with #{opts}"
    @ldap.search(opts) do |entry|
      return entry.respond_to?(obj) ? entry[obj].first.to_s : nil
    end
    msg = "Couldn't find user with id #{id} using #{opts}"
    logger.debug msg
    raise msg
  end

  def modFilter id, field
    # Clone the filter string or else multiple calls to search
    # will modify the same string.
    @filter.clone.insert(-2, "(#{field}=#{id})")
  end

end