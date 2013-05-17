#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'bp'

describe Bp do
  before :each do
    @lookup = Bp.new
  end

  describe ".getManager" do
    it "returns the user's manager's email address" do
      @lookup.getManager("1G4959897").should eql "rleonard@us.ibm.com"
    end

    it "returns nil if the user doesn't have a manager" do
      @lookup.getManager("1G0000000").should eql nil
    end
  end

  describe ".getMail" do
    it "returns a valid email address" do
      @lookup.getMail("1G4959897").should eql "acline@us.ibm.com"
    end

    it "returns nil for a user that doesn't exist" do
      @lookup.getMail("falseuser@us.ibm.com").should eql nil
    end
  end

  describe ".getSerial" do
    it "returns a valid serial number" do
      @lookup.getSerial("acline@us.ibm.com").should eql "1G4959897"
    end

    it "returns nil for a user that doesn't exist" do
      @lookup.getSerial("falseuser@us.ibm.com").should eql nil
    end
  end

end