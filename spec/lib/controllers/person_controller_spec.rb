#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'controllers/person_controller'
require 'controllers/ad_controller'
require 'controllers/bp_controller'

describe PersonController do
  before :each do
    @person = PersonController.new "corpuser", 
      "CN=Corp User,CN=Users,DC=bigdatalab,DC=ibm,DC=com",
      "1G4959897", "rleonard@us.ibm.com", "acline@us.ibm.com"
  end

  describe "#new" do
    it "creates a person" do
      @person.should be_an_instance_of PersonController
      @person.id.should eql "corpuser"
    end
  end

  describe ".log" do
    it "returns an array which has log entries in it" do
      @person.log.should be_an_instance_of Array
    end
  end

  describe ".sync" do
    it "Does all the stuff that the individual sync methods do" do
      expect { @person.sync }.to_not raise_error
    end

    it "raises an error if the person doesn't exist in BP" do
      expect { PersonController.new("cvalcarcel").sync }.to raise_error
    end
  end

  describe ".syncSerial" do
    before :each do
      @ad = AdController.new
      @bp = BpController.new
    end

    it "Assigns the serial number in BP to AD if it's empty" do
      @ad.setSerial(@person.id, "0000").should eql true
      @ad.getSerial(@person.id).should eql "0000"
      @bp.getSerial(@person.mail).should eql "1G4959897"
      @person.syncSerial.should eql true
      @ad.getSerial(@person.id).should eql "1G4959897"
    end

    it "Gets the serial number from AD if it's already set" do
      adsn = @ad.getSerial(@person.id)
      bpsn = @bp.getSerial(@person.mail)
      adsn.should eql bpsn
      @person.syncSerial.should eql true
      @ad.getSerial(@person.id).should eql "1G4959897"
    end

    # It will also return false if it fails to set the serial number in AD,
    # but that's not really reliably testable.
  end

  describe ".syncMail" do
    before :each do
      @ad = AdController.new
      @bp = BpController.new
    end

    it "Assigns the email in BP to AD if it's empty" do
      @ad.setMail(@person.id, "falseuser@us.ibm.com").should eql true
      @ad.getMail(@person.id).should eql "falseuser@us.ibm.com"
      @bp.getMail(@person.sn).should eql "acline@us.ibm.com"
      @person.syncMail.should eql true
      @ad.getMail(@person.id).should eql "acline@us.ibm.com"
    end

    it "Gets the email from AD if it's already set" do
      admail = @ad.getMail(@person.id)
      bpmail = @bp.getMail(@person.sn)
      admail.should eql bpmail
      @person.syncMail.should eql true
      @ad.getMail(@person.id).should eql "acline@us.ibm.com"
    end

    # It will also return false if it fails to set the email in AD,
    # but that's not really reliably testable.
  end

  describe ".syncManager" do
    # The AD server requires a DN for the manager.  This is a problem
    # when a user's manager doesn't have an AD account.  We have to find
    # another field in AD to use for the manager's email.

    before :each do
      @ad = AdController.new
      @bp = BpController.new
    end

    it "Assigns the manager in BP to AD if it's wrong" do
      @ad.setManager(@person.id, "0000", "falseuser@us.ibm.com").should eql true
      @ad.getManagerMail(@person.id).should eql "falseuser@us.ibm.com"
      @ad.getManagerSerial(@person.id).should eql "0000"
      @person.syncManager.should eql true
      @person.getManagerMail.should eql "rleonard@us.ibm.com"
      @person.getManagerSerial.should eql "1G5001897"
    end

    it "Gets the manager from AD if it's already set" do
      admgr = @ad.getManagerSerial(@person.id)
      bpmgr = @bp.getManagerSerial(@person.sn)
      admgr.should eql bpmgr
      @person.syncManager.should eql true
      @person.getManagerMail.should eql "rleonard@us.ibm.com"
      @person.getManagerSerial.should eql "1G5001897"
    end

    # It will also return false if it fails to set the manager in AD,
    # but that's not really reliably testable.
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

  describe ".getManagerMail" do
    it "throws an error if the user doesn't have a serial" do
      expect { PersonController.new("falseuser").getManagerMail }.to raise_error 
    end

    it "returns the user's manager's email address" do
      @person.getManagerMail.should eql "rleonard@us.ibm.com"
    end
  end

  describe ".getManagerSerial" do
    it "throws an error if the user doesn't have a mail" do
      expect { PersonController.new("falseuser").getManagerSerial }.to raise_error 
    end

    it "returns the user's manager's serial" do
      @person.getManagerSerial.should eql "1G5001897"
    end
  end
end