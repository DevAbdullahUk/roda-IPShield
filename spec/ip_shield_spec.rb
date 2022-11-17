# frozen_string_literal: true

require 'roda'
require_relative '../lib/ip_shield'

Request = Struct.new(:ip_add) do
  def ip() ip_add; end
end



RSpec.describe IpShield do
  it "has a version number" do
    expect(IpShield::VERSION).not_to be nil
  end

  it "allows only a valid IPv4 and IPv6" do
    expect do
      class App < Roda
        plugin :ip_shield, '0.0.0.0', ['128.0.0.0', '128.0.0.5']
      end
    end.not_to raise_error
  end

  it "raise error when IP is not a valid IPv4 or IPv6" do
    expect do
      class App < Roda
        plugin :ip_shield, '0.0.X.0', ['128.0.0.0', '1XX.0.0.5']
      end
    end.to raise_error
  end
end
