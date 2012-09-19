require 'spec_helper'
require 'fileutils'

describe OmniStore::Storage::Local do
  before(:each) do
    OmniStore::Config.storage = 'local'
    OmniStore::Config.mountpoint = MOUNTPOINT
    OmniStore::Storage.remount!
  end

  let(:src) { TEST_FILENAME }
  let(:src_fullpath) { expand_path(src, MOUNTPOINT) }

  describe '#mount!' do
    subject { lambda { OmniStore::Storage::Local.mount! } }

    context 'when specified a directory path that exists' do
      it { should_not raise_error }
    end

    context 'when specified two directory paths that exists' do
      before { OmniStore::Config.mountpoint = { :a => MOUNTPOINT, :b => TMPDIR } }
      it { should_not raise_error }
    end

    context 'when specified a directory path that does not exists' do
      before { OmniStore::Config.mountpoint = MOUNTPOINT + Time.new.to_i.to_s }
      it { should raise_error }
    end

    context 'when specified a file path that exists' do
      before { OmniStore::Config.mountpoint = File.expand_path(__FILE__) }
      it { should raise_error }
    end
  end

  describe '#mountpoint' do
    subject { OmniStore::Storage::Local.mountpoint }
    it { should be_a OmniStore::Storage::Local::Mountpoint }
  end

  describe '#exist?' do
    subject { OmniStore::Storage::Local.exist?(src) }

    context 'when specified a file path that does not exist' do
      let(:src) { TEST_FILENAME + Time.new.to_i.to_s }
      it { should be_false } 
    end

    context 'when specified a file path that exist' do
      it { should be_true } 
    end
  end

  describe '#delete' do
    subject { lambda { OmniStore::Storage::Local.delete(src) } }

    context 'when specified a file path that does not exist' do
      let(:src) { TEST_FILENAME + Time.new.to_i.to_s }
      it { should raise_error } 
    end

    context 'when specified a file path that exist' do
      let(:src) { t = Tempfile.new(TEST_FILENAME, MOUNTPOINT); File.basename(t.path) }
      it { should_not raise_error } 
    end
  end

  describe '#each' do
    subject { OmniStore::Storage::Local.each }
    it { should be_a Enumerator }
  end
end
