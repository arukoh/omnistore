# encoding: utf-8
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'bundler/setup'
require 'tempfile'
require 'aws-sdk'
require 'omnistore'

TMPDIR   = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] || '/tmp'
MOUNTPOINT = File.expand_path(File.join(File.dirname(__FILE__), '/../data'))
TEST_FILENAME = 'test.txt'
AWS_BUCKET = 'AWS_BUCKET'

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
