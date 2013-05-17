require 'spec_helper'
require 'configuration'

describe Configuration do
  describe ".config" do
    its(:config) { should be_frozen }
    its(:config) { should be_kind_of(Hash) }
  end

  describe ".initialize" do
    it "loads the environment variables" do
      ENV['BIND_USER'].should_not eql nil
      ENV['BIND_PASS'].should_not eql nil
      ENV['BP_URL'].should_not eql nil
    end
  end
end
