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
        ip_addrs = app.opts[:ip_shield] || ip_addrs
        raise InvalidIP, 'No IP is provided' if ip_addrs.nil? || ip_addrs.empty?

        ip_addrs.each { |ip_addr| IPValidator.instance.add_ip(ip_addr) }
      end

      module RequestMethods
        def is_authorised?
          req_ip_addr = ip_addr(self)

          IPValidator
            .instance
            .is_authorize_ip?(req_ip_addr)
        end

        def must_be_authorised
          req_ip_addr = ip_addr(self)

          IPValidator
            .instance
            .is_authorize_ip?(req_ip_addr)
            .tap { |auth| raise UnauthorisedIP, 'The request IP is not authorised' unless auth }
        end

        def deauthorize_ip
          IPValidator
            .instance
            .remove_ip(ip_addr(self))
        end

        def authorize_ip
          IPValidator
            .instance
            .add_ip(ip_addr(self))
        end

        private

        def ip_addr(request)
          request&.ip.nil? ? (raise InvalidIP, 'No IP is not found') : request.ip
        end

      end
    end

    register_plugin(:ip_shield, IpShield)
  end
end