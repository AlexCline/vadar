#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'bp'

describe Bp do
  before :each do
    @lookup = Bp.new
  end

  describe ".getManagerSerial" do
    it "returns the user's manager's serial" do
      @lookup.getManagerSerial("1G4959897").should eql "1G5001897"
    end

    it "raises an error if the user doesn't have a manager" do
      expect { @lookup.getManagerSerial("1G0000000") }.to raise_error
    end
  end

  describe ".getManagerMail" do
    it "returns the user's manager's email address" do
      @lookup.getManagerMail("1G4959897").should eql "rleonard@us.ibm.com"
    end

    it "raises an error if the user doesn't have a manager" do
      expect { @lookup.getManagerMail("1G0000000") }.to raise_error
    end
  end

  describe ".getMail" do
    it "returns a valid email address" do
      @lookup.getMail("1G4959897").should eql "acline@us.ibm.com"
    end

    it "raises an error if the user doesn't exist" do
      expect { @lookup.getMail("1G0000000") }.to raise_error
    end
  end

  describe ".getSerial" do
    it "returns a valid serial number" do
      @lookup.getSerial("acline@us.ibm.com").should eql "1G4959897"
    end

    it "raises an error if the user doesn't have a serial" do
      expect { @lookup.getSerial("falseuser@us.ibm.com") }.to raise_error
    end
  end

end