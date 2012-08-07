require 'omnistore/config/option'

module OmniStore
  module Config
    extend self
    extend Options

    option :logger,     :default => defined?(Rails)
    option :storage,    :default => 'local'
    option :mountpoint, :default => '/tmp/data'
    option :access_key
    option :secret_key
    option :endpoint
    option :proxy_uri

    def default_logger
      defined?(Rails) && Rails.respond_to?(:logger) ? Rails.logger : ::Logger.new($stdout)
    end

    def logger
      @logger ||= default_logger
    end

    def logger=(logger)
      @logger = case logger
      when false, nil then nil
      when true then default_logger
      else logger.respond_to?(:info) ? logger : @logger
      end
    end
  end
end
