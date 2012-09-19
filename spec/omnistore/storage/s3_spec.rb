require 'spec_helper'

describe "OmniStore::Storage::S3" do

  before(:each) do
    AWS::S3::Bucket.any_instance.stub(:exists?).and_return(true)
    OmniStore::Config.storage = 's3'
    OmniStore::Config.mountpoint = AWS_BUCKET
    OmniStore::Storage.remount!
  end

  describe '#mount!' do
    subject { lambda { OmniStore::Storage::S3.mount! } }

    context 'when specified a bucket name that exists' do
      it { should_not raise_error }
    end

    context 'when specified two bucket names that exists' do
      before { OmniStore::Config.mountpoint = { :a => AWS_BUCKET, :b => AWS_BUCKET } }
      it { should_not raise_error }
    end

    context 'when specified a bucket name that does not exists' do
      before { AWS::S3::Bucket.any_instance.stub(:exists?).and_return(false) }
      it { should raise_error OmniStore::Errors::InvalidMountpoint }
    end
  end

  describe '#mountpoint' do
    subject { OmniStore::Storage::S3.mountpoint }
    it { should be_a OmniStore::Storage::S3::Mountpoint }
  end

  describe '#exist?' do
    let(:src) { TEST_FILENAME }
    subject { OmniStore::Storage::S3.exist?(src) }

    context 'when specified a object that does not exist' do
      before { AWS::S3::S3Object.any_instance.stub(:exists?).and_return(false) }
      it { should be_false } 
    end

    context 'when specified a object that exist' do
      before { AWS::S3::S3Object.any_instance.stub(:exists?).and_return(true) }
      it { should be_true } 
    end
  end

  describe '#delete' do
    let(:src) { TEST_FILENAME }
    before { OmniStore::Storage::S3::Mountpoint.any_instance.stub(:delete).with(src, {}) }
    subject { lambda { OmniStore::Storage::S3.delete(src) } }

    it { should_not raise_error } 
  end

  describe '#read' do
    let(:src) { TEST_FILENAME }
    let(:data) { 'Hello World' }
    before { OmniStore::Storage::S3::Mountpoint.any_instance.stub(:read).with(src, {}).and_yield(data) }
    subject { OmniStore::Storage::S3.read(src){|chunk| chunk } }

    it { should eq data }
  end

  describe '#write' do
    let(:src)  { TEST_FILENAME }
    let(:data) { 'Hello World' }
    before { OmniStore::Storage::S3::Mountpoint.any_instance.stub(:write).with(src, nil, {}) }
    subject { lambda { OmniStore::Storage::S3.write(src) } }

    it { should_not raise_error } 
  end

  describe '#each' do
    subject { OmniStore::Storage::S3.each }
    it { should be_a Enumerator }
  end

end
