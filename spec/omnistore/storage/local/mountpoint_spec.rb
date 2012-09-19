require 'spec_helper'

describe OmniStore::Storage::Local::Mountpoint do
  subject { OmniStore::Storage::Local.mountpoint }

  context 'when single mountpoit' do
    its(:name) { should eq File.basename(MOUNTPOINT) }
    its(:url)  { should eq "file://#{File.expand_path(MOUNTPOINT)}/" }
  end

  context 'when double mountpoint' do
    before do
      OmniStore::Config.mountpoint = { :a => MOUNTPOINT, :b => TMPDIR }
      OmniStore::Storage.remount!
    end
    subject { OmniStore::Storage::Local.mountpoint(:b) }

    its(:name) { should eq :b }
    its(:url)  { should eq "file://#{File.expand_path(TMPDIR)}/" }
  end

  describe '#url' do
    let(:key) { nil }
    subject { OmniStore::Storage::Local.mountpoint.url(key) }

    context 'when key is not specified' do
      it { should eq "file://#{File.expand_path(MOUNTPOINT)}/" }
    end

    context 'when key specified' do
      let(:key) { 'test' }
      it { should eq "file://#{File.expand_path(MOUNTPOINT)}/#{key}" }
    end
  end

  describe '#move' do
    let(:src)   { t = Tempfile.new(TEST_FILENAME, MOUNTPOINT); File.basename(t.path) }
    let(:dst)   { TEST_FILENAME + Time.new.to_i.to_s }
    let(:other) { OmniStore::Storage::Local.mountpoint(:a) }
    subject { lambda { OmniStore::Storage::Local.mountpoint.move(src, dst, other) } }

    before do
      OmniStore::Config.mountpoint = { :a => MOUNTPOINT, :b => TMPDIR }
      OmniStore::Storage.remount!
    end
    after { other.delete(dst) rescue nil }

    context 'when specified a file path that does not exist' do
      let(:src) { TEST_FILENAME + Time.new.to_i.to_s }
      it { should raise_error } 
    end

    context 'when specified a file path that exist' do
      it { should_not raise_error } 
    end

    context 'when move to another mountpoint' do
      let(:other) { OmniStore::Storage::Local.mountpoint(:b) }
      it { should_not raise_error } 
    end
  end
end
