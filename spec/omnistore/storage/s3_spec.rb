require 'spec_helper'
require 'fileutils'

describe "OmniStore::Storage::S3" do

  before(:each) do
    OmniStore::Config.storage = 's3'
    OmniStore::Config.mountpoint = AWS_BUCKET
    OmniStore::Storage.remount!
  end

  it 'should mount' do
    OmniStore::Storage::S3.mount!.should_not be_nil
  end

  it 'should raise error when mount fails' do
    OmniStore::Config.mountpoint = "a"
    lambda { OmniStore::Storage::S3.mount! }.should raise_error(OmniStore::Errors::InvalidMountpoint)
  end

  it 'should exist' do
    key = 'test.txt'
    OmniStore::Storage::S3.write(key, '')
    begin
      OmniStore::Storage::S3.exist?(key).should be_true
      OmniStore::Storage::S3.exist?(key+'.bk').should be_false
    ensure
      OmniStore::Storage::S3.delete(key)
    end
  end

end
