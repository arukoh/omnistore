require 'spec_helper'
require 'fileutils'

describe OmniStore::Storage::Local do

  def expand_path(path, mountpoint = OmniStore::Config.mountpoint)
    File.expand_path(path, mountpoint)
  end

  before(:each) do
    OmniStore::Config.storage = 'local'
    OmniStore::Config.mountpoint = MOUNTPOINT
  end

  describe "#mount!" do
    it 'should not raise error' do
      OmniStore::Config.mountpoint = MOUNTPOINT
      lambda { OmniStore::Storage::Local.mount! }.should_not raise_error
    end

    it 'should not raise error when hash mountpoint' do
      OmniStore::Config.mountpoint = { :a => MOUNTPOINT, :b => TMPDIR }
      lambda { OmniStore::Storage::Local.mount! }.should_not raise_error
    end

    it 'should raise error when mount fails' do
      OmniStore::Config.mountpoint = nil
      lambda { OmniStore::Storage::Local.mount! }.should raise_error(OmniStore::Errors::InvalidMountpoint)
    end
  end

  context "single mountpoint" do
    let(:src) { 'test.txt' }
    let(:src_fullpath) { expand_path(src) }

    before(:each) do
      OmniStore::Config.mountpoint = MOUNTPOINT
      OmniStore::Storage.remount!
      FileUtils.touch(src_fullpath)
    end
    after(:each)  { FileUtils.rm_f(src_fullpath) }

    describe "#exist?" do
      it 'should return true' do
        OmniStore::Storage::Local.exist?(src).should be_true
      end

      it 'should return false' do
        OmniStore::Storage::Local.exist?(src + '.bk').should be_false
      end
    end

    describe "#delete" do
      it 'should return true' do
        lambda { OmniStore::Storage::Local.delete(src) }.should_not raise_error
        File.exist?(src_fullpath).should be_false
      end
    end

    describe "#move" do
      let(:dst) { src + '.mv' }
      let(:dst_fullpath) { expand_path(dst) }
      let(:mountpoint) { OmniStore::Storage::Local.mountpoint(MOUNTPOINT) }
      after(:each)  { FileUtils.rm_f(dst_fullpath) }

      it 'should move to target path' do
        lambda { mountpoint.move(src, dst) }.should_not raise_error
        File.exist?(src_fullpath).should be_false
        File.exist?(dst_fullpath).should be_true
      end

      it 'should raise error when source file is not exists' do
        lambda { mountpoint.move(dst, src) }.should raise_error
      end
    end
  end

  context "dounble mountpoint" do
    let(:src) { 'test.txt' }
    let(:src_fullpath) { expand_path(src, MOUNTPOINT) }

    before(:each) do
      OmniStore::Config.mountpoint = { :a => MOUNTPOINT, :b => TMPDIR }
      OmniStore::Storage.remount!
      FileUtils.touch(src_fullpath)
    end
    after(:each)  { FileUtils.rm_f(src_fullpath) }

    describe "#exist?" do
      it 'should return true' do
        OmniStore::Storage::Local.exist?(src).should be_true
      end

      it 'should return false' do
        OmniStore::Storage::Local.exist?(src + '.bk').should be_false
      end
    end

    describe "#delete" do
      it 'should return true' do
        lambda { OmniStore::Storage::Local.delete(src) }.should raise_error
      end
    end

    describe "#move" do
      let(:dst) { src + '.mv' }
      let(:dst_fullpath) { expand_path(dst, TMPDIR) }
      let(:mountpoint)   { OmniStore::Storage::Local.mountpoint(:a) }
      let(:another)      { OmniStore::Storage::Local.mountpoint(:b) }
      after(:each)  { FileUtils.rm_f(dst_fullpath) }

      it 'should move to target path of another mountpoint' do
        lambda { mountpoint.move(src, dst, another) }.should_not raise_error
        File.exist?(src_fullpath).should be_false
        File.exist?(File.join(MOUNTPOINT, dst)).should be_false
        File.exist?(File.join(TMPDIR, dst)).should be_true
      end
    end
  end
end
