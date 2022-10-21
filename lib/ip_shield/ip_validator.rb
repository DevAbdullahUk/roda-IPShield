require "ipaddr"
require 'singleton'

class IPValidator
  include Singleton
  attr_accessor :ips

  class InvalidIPsBoundary < StandardError; end
  class InvalidIP < StandardError; end

  IP_DOES_NOT_EXIST = 'the given IP is not within the authorised list'
  INVALID_BOUNDARY = 'IP boundary must be an array of 2 elements: high and low'
  INVALID_IP = 'IP must be a valid IPv4 or IPv6'

  def initialize
    @ips = []
  end

  def check_ips(ip_addr_list = @ips)
    ip_addr_list && ip_addr_list.each do |ip_addr|
      if ip_addr.is_a?(Array)
        ip_addr
          .tap { |ip| raise InvalidIPsBoundary, INVALID_BOUNDARY unless ip.count.eql?(2) }
          .each { |ip| raise InvalidIP, INVALID_IP unless is_ip?(ip) }
      else
        raise InvalidIP, INVALID_IP unless is_ip?(ip_addr)
      end
    end

    return_slef
  end

  def add_ip(ip_addr)
    check_ips([ip_addr]) && @ips.push(ip_addr)
    return_slef
  end


  def remove_ip(ip_addr)
    raise InvalidIP, IP_DOES_NOT_EXIST if @ips.delete(ip_addr).nil?
    return_slef
  end

  private

  def is_ip?(ip_addr = @ips)
    return false if ip_addr.nil?
    return false unless ip_addr.is_a? String

    true if IPAddr.new(ip_addr) rescue false
  end

  def return_slef() self; end

end