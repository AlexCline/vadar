#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'person'

describe Person do
  before :each do
    @person = Person.new "cline"
  end

  describe "#new" do
    it "creates a person" do
      @person.should be_an_instance_of Person
      @person.id.should eql "cline"
    end
  end

  describe ".getSerial" do
    it "raises an error if the serial number is not in AD or BP" do
      expect { Person.new("falseuser").getSerial }.to raise_error
    end

    it "returns the user's serial number" do
      @person.getSerial
      @person.sn.should eql "1G4959897"
    end
  end

  describe ".getMail" do
    it "raises an error if the user doesn't have an email address in AD or BP" do
      expect { Person.new("falseuser").getMail }.to raise_error
    end

    it "returns the user's email address" do
      @person.getMail
      @person.mail.should eql "acline@us.ibm.com"
    end
  end

  describe ".getManager" do
    it "throws an error if the user doesn't have a serial" do
      expect { Person.new("falseuser").getManager }.to raise_error 
    end

    it "returns the user's manager's email address" do
      @person.getSerial
      @person.getManager
      @person.mgr.should eql "rleonard@us.ibm.com"
    end
  end
end