#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'ad'

describe Ad do
  before :each do
    @lookup = Ad.new
  end

  describe ".getManager" do
    it "returns nothing until the manager field is populated"  do
      @lookup.getManager("cline").should eql nil
    end

    it "returns nil when the user doesn't have a manager specified" do
      @lookup.getManager("PassManager").should eql nil
    end

  end

  describe ".getMail" do
    it "returns a valid email address" do
      @lookup.getMail("cline").should eql "acline@us.ibm.com"
    end

    it "raises an error when the user doesn't exist" do
      expect { @lookup.getMail("falseuser") }.to raise_error
    end

    it "returns nil when the user doesn't have an email address" do
      @lookup.getMail("PassManager").should eql nil
    end
  end
  
  describe ".getSerial" do
    it "returns a valid serial number" do
      @lookup.getSerial("cline").should eql "1G4959897"
    end

    it "raises an error when the user doesn't exist" do
      expect { @lookup.getSerial("falseuser") }.to raise_error
    end

    it "returns nil when the user doesn't have a serial number" do
      @lookup.getSerial("PassManager").should eql nil
    end
  end

  describe ".userFiler" do
    it "returns a filter for one user" do
      @lookup.userFilter('cline').should 
        eql "(&(objectClass=person)(!(objectClass=computer))\
          (!(userAccountControl:1.2.840.113556.1.4.803:=2))\
          (sAMAccountName=cline))"
    end
  end

end