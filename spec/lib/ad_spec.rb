#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'ad'

describe Ad do
  before :each do
    @ad = Ad.new
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

  describe ".connected?" do
    it "returns true if the connection is alive" do
      @ad.connected?.should eql true
    end

    # It will also raise an error if the connection isn't alive,
    # but that's hard to test without an actual failed connection.
  end

  describe ".getIdFromSerial" do
    it "returns an id when passed a serial" do
      @ad.getIdFromSerial("1G4959897")
    end
  end

  describe ".getId" do
    it "returns an id when passed a DN" do
      @ad.getId("CN=Alex Cline,CN=Users,DC=bigdatalab,DC=ibm,DC=com").should
        eql "cline"
    end

    it "raises an error if it couldn't find the user" do
      expect{ @ad.setSerial("falseuser", "0000")}.to raise_error
    end
  end

  describe ".setSerial" do
    it "returns true if the serial was set successfully" do
      @ad.setSerial("cline", "1G4959897").should eql true
    end

    it "raises an error if it couldn't find the user" do
      expect{ @ad.setSerial("falseuser", "0000")}.to raise_error
    end
  end

  describe ".setMail" do
    it "returns true if the serial was set successfully" do
      @ad.setMail("cline", "acline@us.ibm.com").should eql true
    end

    it "raises an error if it couldn't find the user" do
      expect{ @ad.setMail("falseuser", "f@example.com")}.to raise_error
    end
  end

  describe ".setManager" do
    it "returns true if the manager was set successfully" do
      @ad.setManager("cline", "1G5001897", "rleonard@us.ibm.com").should eql true
    end

    it "raises an error if it couldn't find the user" do
      expect{ @ad.setManager("falseuser", "0000", "trueuser@us.ibm.com")}.to raise_error
    end
  end

  describe ".getDN" do
    it "returns a valid DN" do
      @ad.getDN("cline").should 
        eql "CN=Alex Cline,CN=Users,DC=bigdatalab,DC=ibm,DC=com"
    end

    it "raises an error when the user doesn't exist" do
      expect { @ad.getDN("falseuser") }.to raise_error
    end
  end

  describe ".getManagerMail" do
    it "returns the email of the manager"  do
      @ad.getManagerMail("cline").should eql "rleonard@us.ibm.com"
    end

    it "returns nil when the user doesn't have a manager specified" do
      @ad.getManagerMail("PassManager").should eql nil
    end

    it "raises an error when the user doesn't exist" do
      expect { @ad.getManagerMail("falseuser") }.to raise_error
    end
  end

  describe ".getManagerSerial" do
    it "returns the email of the manager"  do
      @ad.getManagerSerial("cline").should eql "1G5001897"
    end

    it "returns nil when the user doesn't have a manager specified" do
      @ad.getManagerSerial("PassManager").should eql nil
    end

    it "raises an error when the user doesn't exist" do
      expect { @ad.getManagerSerial("falseuser") }.to raise_error
    end
  end

  describe ".getMail" do
    it "returns a valid email address" do
      @ad.getMail("cline").should eql "acline@us.ibm.com"
    end

    it "raises an error when the user doesn't exist" do
      expect { @ad.getMail("falseuser") }.to raise_error
    end

    it "returns nil when the user doesn't have an email address" do
      @ad.getMail("PassManager").should eql nil
    end
  end
  
  describe ".getSerial" do
    it "returns a valid serial number" do
      @ad.getSerial("cline").should eql "1G4959897"
    end

    it "raises an error when the user doesn't exist" do
      expect { @ad.getSerial("falseuser") }.to raise_error
    end

    it "returns nil when the user doesn't have a serial number" do
      @ad.getSerial("PassManager").should eql nil
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