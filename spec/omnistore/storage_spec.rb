require 'spec_helper'

describe OmniStore::Storage do

  it 'should return storage' do
    OmniStore::Config.storage = 'local'
    OmniStore::Storage.remount!
    OmniStore::Storage.storage.should == OmniStore::Storage::Local
  end

  it 'should return storage for s3' do
    OmniStore::Config.storage = 's3'
    OmniStore::Storage.remount!
    OmniStore::Storage.storage.should == OmniStore::Storage::S3 
  end

  it 'should return storage when remount' do
    OmniStore::Storage.remount!
    OmniStore::Storage.storage.should_not be_nil
  end

end
