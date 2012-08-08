require 'spec_helper'
require 'fileutils'

describe OmniStore::Storage::Local do

  before(:each) do
    OmniStore::Config.storage = 'local'
    OmniStore::Config.mountpoint = MOUNTPOINT
    OmniStore::Storage.remount!
  end

  it 'should mount' do
    OmniStore::Storage::Local.mount!.should_not be_nil
  end

  it 'should raise error when mount fails' do
    OmniStore::Config.mountpoint = nil
    lambda { OmniStore::Storage::Local.mount! }.should raise_error(OmniStore::Errors::InvalidMountpoint)
  end

  it 'should exist' do
    path = 'test.txt'
    expand_path = File.expand_path(path, OmniStore::Config.mountpoint)
    FileUtils.touch(expand_path)
    begin
      OmniStore::Storage::Local.exist?(path).should be_true
      OmniStore::Storage::Local.exist?(path+'.bk').should be_false
    ensure
      OmniStore::Storage::Local.delete(path)
    end
  end

end
