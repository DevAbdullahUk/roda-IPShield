require "ipaddr"
require "singleton"

#
class IPValidator
  include Singleton
  attr_accessor :ips

  class InvalidIPsBoundary < StandardError; end

  class InvalidIP < StandardError; end

  INVALID_BOUNDARY = "IP boundary must be an array of 2 elements: high and low".freeze
  IP_DOES_NOT_EXIST = "the given IP is not within the authorised list".freeze
  INVALID_IP = "IP must be a valid IPv4 or IPv6".freeze

  def initialize() @ips = []; end

  # Ensure that all IPs are valid. an IP is invalid if its nil, not a string, or not in a IPv4 or
  # IPv6 format. In case of a boundary-ip, it also must also be an array of 2
  # elements (ex. [high, low]). if one or more IP in the list is invalid,
  # it will raise an error. Otherwise, it will return self
  #
  # @example
  #   invalid_ip = ['0.0....']
  #   invalid_ip.each {|ip| IPValidator.instance.add_ip(ip)}
  #
  #   IPValidator.instance.check_ips # will raise InvalidIP error
  #
  # @raise
  #   * InvalidIPsBoundary: if the array has an invalid number of elements.
  #   * InvalidIP: if the IP address is invalid
  #
  # @param [Array] ip_addr_list a list of all IP address
  # @return [IPValidator] will return self unless one or more IP is invalid
  def check_ips(ip_addr_list = @ips)
    ip_addr_list.each do |ip_addr|
      if ip_addr.is_a?(Array)
        ip_addr
          .tap { |ip| raise InvalidIPsBoundary, INVALID_BOUNDARY unless ip.count.eql?(2) }
          .each { |ip| raise InvalidIP, INVALID_IP unless is_ip?(ip) }
      else
        raise InvalidIP, INVALID_IP unless is_ip?(ip_addr)
      end
    end

    return_self
  end

  # Checks if the IP is authorized. The IP is authorized if any of the following true:
  # 1. the IP matches on of the IPs in the list +@ips+
  # 2. the IP is within any IP boundaries in +@ips+
  # this function will return true if any 1 or 2 is true. Otherwise, it will return false.
  #
  # @example
  #  IPValidator
  #     .instance
  #     .is_authorize_ip?('0.0.0.0')
  #
  # @param [String] ip_addr the IP address
  # @return [TrueClass, FalseClass] true if the IP is authorized. Otherwise return false
  def is_authorize_ip?(ip_addr)
    ip_range, ip_list = @ips.partition{|all_ips| all_ips.is_a? Array}

    ip_list.filter!{|ip| IPAddr.new(ip).to_i === IPAddr.new(ip_addr).to_i}
    ip_list.empty? && ip_range.filter! do |range|
      low = IPAddr.new(range.first)
      high = IPAddr.new(range.last)
      current = IPAddr.new(ip_addr)

      (low..high)===current
    end

    (ip_list.count + ip_range.count).positive?
  end

  def add_ip(ip_addr)
    check_ips([ip_addr]) && @ips.push(ip_addr)
    return_self
  end

  def remove_ip(ip_addr)
    raise InvalidIP, IP_DOES_NOT_EXIST if @ips.delete(ip_addr).nil?
    return_self
  end

  private

  def is_ip?(ip_addr = @ips)
    return false if ip_addr.nil?
    return false unless ip_addr.is_a? String

    true if IPAddr.new(ip_addr) rescue false
  end

  def return_self() self; end
end