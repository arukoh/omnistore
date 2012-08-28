require 'spec_helper'
require 'fileutils'

describe "OmniStore::Storage::S3" do

  def create_object(src, key = AWS_BUCKET)
    OmniStore::Storage::S3.mountpoint(key).bucket.objects[src].write('Hello World!')
  end

  def delete_object(src, key = AWS_BUCKET)
    OmniStore::Storage::S3.mountpoint(key).bucket.objects[src].delete
  end

  before(:each) do
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
      before { OmniStore::Config.mountpoint = AWS_BUCKET + Time.new.to_i.to_s }
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
      it { should be_false } 
    end

    context 'when specified a object that exist' do
      before { create_object(src) }
      after  { delete_object(src) }
      it { should be_true } 
    end
  end

  describe '#delete' do
    let(:src) { TEST_FILENAME }
    subject { lambda { OmniStore::Storage::S3.delete(src) } }

    context 'when specified a object that does not exist' do
      it { should_not raise_error } 
    end

    context 'when specified a object path that exist' do
      before { create_object(src) }
      it 'should delete object' do
        should_not raise_error
        OmniStore::Storage::S3.exist?(src).should be_false
      end
    end
  end

  describe '#each' do
    subject { OmniStore::Storage::S3.each }
    it { should be_a Enumerator }
  end

  describe 'OmniStore::Storage::S3::Mountpoint' do
    subject { OmniStore::Storage::S3.mountpoint }

    context 'when single mountpoit' do
      its(:name) { should eq AWS_BUCKET }
      its(:url)  { should match "#{AWS_BUCKET}" }
    end

    context 'when double mountpoint' do
      before do
        OmniStore::Config.mountpoint = { :a => AWS_BUCKET, :b => AWS_BUCKET }
        OmniStore::Storage.remount!
      end
      subject { OmniStore::Storage::S3.mountpoint(:b) }

      its(:name) { should eq :b }
      its(:url)  { should match "#{AWS_BUCKET}" }
    end

    describe '#url' do
      let(:key) { nil }
      let(:options) { {} }
      subject { OmniStore::Storage::S3.mountpoint.url(key, options) }

      context 'when key is not specified' do
        it { should match "#{AWS_BUCKET}" }
      end

      context 'when key specified' do
        let(:key) { 'test' }
        it { should match "#{AWS_BUCKET}.+/#{key}" }
      end

      context 'when secure is true' do
        let(:key) { 'test' }
        let(:options) { { :secure => true } }
        it { should match "^https://.*#{AWS_BUCKET}.*/#{key}" }
      end

      context 'when secure is false' do
        let(:key) { 'test' }
        let(:options) { { :secure => false } }
        it { should match "^http://.*#{AWS_BUCKET}.*/#{key}" }
      end

    end

    describe '#move' do
      let(:src) { TEST_FILENAME }
      let(:dst)   { TEST_FILENAME + Time.new.to_i.to_s }
      let(:other) { OmniStore::Storage::S3.mountpoint(:a) }
      subject { lambda { OmniStore::Storage::S3.mountpoint.move(src, dst, other) } }

      before do
        OmniStore::Config.mountpoint = { :a => AWS_BUCKET, :b => AWS_BUCKET }
        OmniStore::Storage.remount!
      end
 
      context 'when specified a object that does not exist' do
        it { should raise_error AWS::S3::Errors::NoSuchKey } 
      end

      context 'when specified a object that exist' do
        before { create_object(src, :a) }
        after  { delete_object(dst, :a) }
        it { should_not raise_error } 
      end

      context 'when move to another mountpoint' do
        before { create_object(src, :a) }
        after  { delete_object(dst, :b) }
        let(:other) { OmniStore::Storage::S3.mountpoint(:b) }
        it { should_not raise_error } 
      end
    end
  end
end
