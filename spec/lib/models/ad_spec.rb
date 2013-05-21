#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'models/ad'

describe Ad do
  before :each do
    @ad = Ad.new
  end

  describe ".connected?" do
    it "returns true if the connection is alive" do
      @ad.connected?.should eql true
    end

    # It will also raise an error if the connection isn't alive,
    # but that's hard to test without an actual failed connection.
  end

  describe ".getAllAccounts" do
    it "returns an array" do
      @ad.getAllAccounts.should be_an_instance_of Array
    end

    it "returns an array with more than 0 entries" do
      @ad.getAllAccounts.size.should > 0
    end

    it "return an array of hashes of account information" do
      @ad.getAllAccounts.each{ |user|
        user.should be_an_instance_of Hash
      }
    end
  end

  describe ".modFiler" do
    it "returns a filter for one user" do
      @ad.modFilter('cline', 'sAMAccountName').should 
        eql "(&(objectClass=person)(!(objectClass=computer))\
          (!(userAccountControl:1.2.840.113556.1.4.803:=2))\
          (sAMAccountName=cline))"
    end
  end

end