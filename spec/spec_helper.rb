# encoding: utf-8
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'rspec'
require 'aws-sdk'
require 'omnistore'

MOUNTPOINT = File.join(File.dirname(__FILE__), '/../data')
AWS_BUCKET = ENV['AWS_BUCKET']

OmniStore.configure do |config|
  config.storage = 'local'
  config.mountpoint = MOUNTPOINT
end

RSpec.configure do |config|

  config.before(:each) do
  end

  config.after(:each) do
    OmniStore::Config.reset_logger 
    OmniStore::Config.storage = 'local'
    OmniStore::Config.mountpoint = MOUNTPOINT
    OmniStore::Config.reset_access_key
    OmniStore::Config.reset_secret_key
    OmniStore::Config.reset_endpoint
    OmniStore::Config.reset_proxy_uri
    OmniStore.logger.level = Logger::FATAL
  end
end
