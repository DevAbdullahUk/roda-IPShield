# frozen_string_literal: true

require_relative "ip_shield/version"
require_relative "ip_shield/ip_validator"
require "ipaddr"

class Roda
  module RodaPlugins
    module IpShield
      class UnauthorisedIP < RodaError; end
      class InvalidIP < RodaError; end

      #
      # @param [Object] app App
      # @param [Array] ip_addrs list of aip addresses
      def self.configure(app, *ip_addrs)
        ip_addrs =  app.opts[:ip_shield] || ip_addrs
        raise InvalidIP, 'No IP is provided' if ip_addrs.nil? || ip_addrs.empty?

        ip_addrs.each { |ip_addr| IPValidator.instance.add_ip(ip_addr) }
      end

      module RequestMethods
        def is_authorised?
          IPValidator.instance
        end

        def must_be_authorised

        end

        def deauthorize_ip
          raise InvalidIP, 'No IP is not found' if self&.ip.nil?
          IPValidator.instance.remove_ip(self.ip)
        end

        def authorize_ip
          raise InvalidIP, 'No IP is not found' if self&.ip.nil?
          IPValidator.instance.add_ip(self.ip)
        end

      end

    end

    register_plugin(:ip_shield, IpShield)
  end
end