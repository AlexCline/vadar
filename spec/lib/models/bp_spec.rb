#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'models/bp'

describe Bp do
  before :each do
    @bp = Bp.new
  end

  describe "#new" do
    it "has a url defined" do
      @bp.url.should_not eql nil
    end
  end

  describe ".connected?" do
    it "returns true when connection to BP is available" do
      @bp.connected?.should eql true
    end
  end

  describe ".search" do
    it "returns a person entry when searching for a user by serial" do
      @bp.search("serialnumber", "1G4959897").should be_instance_of Array
    end

    it "returns nil when searching for a person that doesn't exist by serial" do
      @bp.search("serialnumber", "0000").should eql nil
    end

    it "returns a person entry when searching for a user by email" do
      @bp.search("mail", "acline@us.ibm.com").should be_instance_of Array
    end

    it "returns nil when searching for a person that doesn't exist by mail" do
      @bp.search("mail", "falseuser@us.ibm.com").should eql nil
    end
  end

end