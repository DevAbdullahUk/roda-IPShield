# frozen_string_literal: true

require_relative "ip_shield/version"
require_relative "ip_shield/ip_validator"
require "ipaddr"
require 'roda'
class Roda
  module RodaPlugins
    module IpShield

      # Unauthorised IP error
      class UnauthorisedIP < RodaError; end

      # invalid IP error
      class InvalidIP < RodaError; end

      # Auto configure +ip_shield+ plugin. Set IPs when the plugin is loaded. The provided
      # IP will be authorize automatically as long as they as are valid IPv4 or IPv6. There are
      # two ways to set IP.
      # 1. As a string. Ex; '0.0.0.0'
      # 2. As an array of low and high boundaries. Ex; ['0.0.0.0', '0.0.0.7']
      #
      # @note
      # boundaries should be an array with two string elements - IP. The first element must
      # be low IP and the second should be high.
      #
      # @example
      #    plugin :ip_shield, '0.0.0.0', ['128.0.0.0', '128.0.0.5']
      #
      # @param [Object] app App
      # @param [Array] ip_addrs list of aip addresses
      def self.configure(app, *ip_addrs)
        ip_addrs = app.opts[:ip_shield] || ip_addrs
        ip_addrs.each { |ip_addr| IPValidator.instance.add_ip(ip_addr) } unless ip_addrs.nil? || ip_addrs.empty?
      end

      module RequestMethods

        # A simple but fun way to check if the request IP is authorised. Only added IPs are
        # authorised. If the IP is not added, then it will be considered as deauthorise ip and
        # therefore this function will return false.
        #
        # @example
        #   r.authorised_ip? ? 'IP is authorised' : 'IP is not authorised'
        #
        # @return [TrueClass, FalseClass] true only if the request IP is authorised & false if not
        def authorised_ip?
          req_ip_addr = ip_addr(self)

          IPValidator
            .instance
            .is_authorize_ip?(req_ip_addr)
        end

        # This function will raise +UnauthorisedIP+ error if the request IP is not authorised.
        # Use this function if you would like to hard-stop the program execution but be
        # sure to handle the error.
        #
        # @example
        #   begin
        #   r.must_be_authorised_ip
        #   'IP is authorised'
        #   rescue UnauthorisedIP
        #   'IP is not authorised'
        #   end
        #
        # @raise
        #   UnauthorisedIP: The request IP is not authorised'
        #
        # @return [TrueClass, FalseClass] true if IP is authorised or raise UnauthorisedIP when isn't
        def must_be_authorised_ip
          req_ip_addr = ip_addr(self)

          IPValidator
            .instance
            .is_authorize_ip?(req_ip_addr)
            .tap { |auth| raise UnauthorisedIP, 'The request IP is not authorised' unless auth }
        end

        # Remove an IP from the authorised list. The IP must be valid and exist in the
        # authorised IP list. Its recommended to check if the IP exist before deauthorise it.
        #
        # @example
        #   r.deauthorise_ip if r.authorised_ip?
        #
        # @raise
        #   IP_DOES_NOT_EXIST: the given IP is not within the authorised list
        def deauthorise_ip
          IPValidator
            .instance
            .remove_ip(ip_addr(self))
        end

        # Add an IP ti the authorised list. You can only add any of the following:
        # 1. IP as a string. Ex; '0.0.0.0'
        # 2. An array of low and high boundaries. Ex; ['0.0.0.0', '0.0.0.7']
        #
        # @note
        # The IP validity will get checked automatically before it gets added to the
        # authorise IP list. However, there are no checks for duplicate IPs. Its
        # recommended to check if the IP exist before authorise it.
        #
        # @example
        #   r.authorise_ip unless r.authorised_ip?
        #
        # @return [String|Array] an IP as a string or an IP boundary
        def authorise_ip
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

