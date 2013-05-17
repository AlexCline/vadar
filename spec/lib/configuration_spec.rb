require 'spec_helper'
require 'configuration'

describe Configuration do
  describe ".config" do
    its(:config) { should be_frozen }
    its(:config) { should be_kind_of(Hash) }
  end

  describe ".initialize" do
    it "loads the env_var BIND_USER" do
      ENV['BIND_USER'].should_not eql nil
    end
    it "loads the env_var BIND_PASS" do
      ENV['BIND_PASS'].should_not eql nil
    end
    it "loads the env_var BP_URL" do
      ENV['BP_URL'].should_not eql nil
    end
  end
end
