require 'spec_helper'

describe OmniStore::Config do

  it 'should return logger' do
    OmniStore::Config.logger = true
    OmniStore::Config.logger.class.should == ::Logger
  end

  it 'should return logger when set false' do
    OmniStore::Config.logger = false
    OmniStore::Config.logger.class.should == ::Logger
  end

  it 'should return logger when set nil' do
    OmniStore::Config.logger = nil
    OmniStore::Config.logger.class.should == ::Logger
  end

  it 'should return Rails logger for Rails apps' do
    class Rails; end
    class MyLogger < Logger; end
    Rails.stub(:logger) { MyLogger.new($stdout) }
    OmniStore::Config.logger = true
    OmniStore::Config.logger.class.should == ::MyLogger
  end

  it 'should return storage' do
    OmniStore::Config.storage = 'local'
    OmniStore::Config.storage.should == 'local'
  end

  it 'should return mountpoint' do
    OmniStore::Config.mountpoint = '/tmp/data'
    OmniStore::Config.mountpoint.should == '/tmp/data'
  end

  it 'should return access_key' do
    OmniStore::Config.access_key = 'key'
    OmniStore::Config.access_key.should == 'key'
  end

  it 'should return secret_key' do
    OmniStore::Config.secret_key = 'secret'
    OmniStore::Config.secret_key.should == 'secret'
  end

  it 'should return endpoint' do
    OmniStore::Config.endpoint = 'endpoint'
    OmniStore::Config.endpoint.should == 'endpoint'
  end

end
