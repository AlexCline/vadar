#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'vadar'

describe Vadar do
  before :each do
    @vadar = Vadar.new
  end

  describe "#new" do
    it "should exist" do
      @vadar.should be_an_instance_of Vadar
    end
  end

  describe ".lookupAccounts" do
  	it "returns an array of all user accounts" do
      @vadar.lookupAccounts.should be_an_instance_of Array
      #puts @vadar.lookupAccounts.inspect
  	end
  end
end