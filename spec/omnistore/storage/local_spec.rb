require 'spec_helper'
require 'fileutils'

describe OmniStore::Storage::Local do

  it 'should mount' do
    OmniStore::Storage::Local.mount!.should_not be_nil
  end

  it 'should raise error when mount fails' do
    OmniStore::Config.mountpoint = nil
    lambda { OmniStore::Storage::Local.mount! }.should raise_error(OmniStore::Errors::InvalidMountpoint)
  end

  it 'should exist' do
    path = 'test.txt'
    FileUtils.touch(File.join(OmniStore::Config.mountpoint, path))
    OmniStore::Storage::Local.exist?(path).should be_true
    OmniStore::Storage::Local.exist?(path+'.bk').should be_false
  end

end
