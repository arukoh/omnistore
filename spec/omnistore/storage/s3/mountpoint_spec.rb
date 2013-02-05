require 'spec_helper'

describe 'OmniStore::Storage::S3::Mountpoint' do
  
  before(:each) do
    AWS::S3::Bucket.any_instance.stub(:exists?).and_return(true)
    OmniStore::Config.storage = 's3'
    OmniStore::Config.mountpoint = AWS_BUCKET
    OmniStore::Storage.remount!
  end

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
      it { should match "#{AWS_BUCKET}/#{key}" }
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

  describe '#delete' do
    let(:src) { TEST_FILENAME }
    before { AWS::S3::S3Object.any_instance.stub(:delete).with({}) }
    subject { lambda { OmniStore::Storage::S3.mountpoint.delete(src) } }

    it { should_not raise_error } 
  end

  describe '#read' do
    let(:src) { TEST_FILENAME }
    let(:data) { 'Hello World' }
    before { AWS::S3::S3Object.any_instance.stub(:read).and_yield(data) }
    subject { OmniStore::Storage::S3.mountpoint.read(src){|chunk| chunk } }

    it { should eq data }
  end

  describe '#write' do
    let(:src)  { TEST_FILENAME }
    let(:data) { 'Hello World' }
    before { AWS::S3::S3Object.any_instance.stub(:write).with(data, {}) }
    subject { lambda { OmniStore::Storage::S3.mountpoint.write(src, data) } }

    it { should_not raise_error } 
  end

  describe '#move' do
    let(:src) { TEST_FILENAME }
    let(:dst)   { TEST_FILENAME + Time.new.to_i.to_s }
    let(:other) { OmniStore::Storage::S3.mountpoint(:a) }
    subject { lambda { OmniStore::Storage::S3.mountpoint.move(src, dst, other) } }

    before do
      OmniStore::Config.mountpoint = { :a => AWS_BUCKET, :b => AWS_BUCKET + 'b' }
      OmniStore::Storage.remount!
    end

    context 'when move to same mountpoint' do
      before do
        AWS::S3::S3Object.any_instance.stub(:move_to).with do |*args|
          args[0].should eq dst
          args[1][:bucket_name].should eq AWS_BUCKET
          true
        end
      end
      it { should_not raise_error } 
    end

    context 'when move to another mountpoint' do
      before do
        AWS::S3::S3Object.any_instance.stub(:move_to).with do |*args|
          args[0].should eq dst
          args[1][:bucket_name].should eq other.bucket.name
          true
        end
      end
      let(:other) { OmniStore::Storage::S3.mountpoint(:b) }
      it { should_not raise_error } 
    end
  end

  describe '#copy' do
    let(:src) { TEST_FILENAME }
    let(:dst)   { TEST_FILENAME + Time.new.to_i.to_s }
    let(:other) { OmniStore::Storage::S3.mountpoint(:a) }
    subject { lambda { OmniStore::Storage::S3.mountpoint.copy(src, dst, other) } }

    before do
      OmniStore::Config.mountpoint = { :a => AWS_BUCKET, :b => AWS_BUCKET + 'b' }
      OmniStore::Storage.remount!
    end

    context 'when copy to same mountpoint' do
      before do
        AWS::S3::S3Object.any_instance.stub(:copy_to).with do |*args|
          args[0].should eq dst
          args[1][:bucket].name.should eq AWS_BUCKET
          true
        end
      end
      it { should_not raise_error } 
    end

    context 'when copy to another mountpoint' do
      before do
        AWS::S3::S3Object.any_instance.stub(:copy_to).with do |*args|
          args[0].should eq dst
          args[1][:bucket].name.should eq other.bucket.name
          true
        end
      end
      let(:other) { OmniStore::Storage::S3.mountpoint(:b) }
      it { should_not raise_error } 
    end
  end
end
