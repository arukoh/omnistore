require 'spec_helper'
require 'fileutils'

describe "OmniStore::Storage::S3" do

  before(:each) do
    OmniStore::Config.storage = 's3'
    OmniStore::Config.mountpoint = ENV['AWS_BUCKET']
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
    path = 'test.txt'
    OmniStore::Storage::S3.write(path, '')
    OmniStore::Storage::S3.exist?(path).should be_true
    OmniStore::Storage::S3.exist?(path+'.bk').should be_false
  end

end
