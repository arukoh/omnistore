require 'aws-sdk'

module OmniStore
  module Storage
    module S3
      extend self

      @@bucket = nil

      def mount!
        bucket = AWS::S3.new(options).buckets[OmniStore::Config.mountpoint]
        raise OmniStore::Errors::InvalidMountpoint unless bucket.exists?
        @@bucket = bucket
      end

      def exist?(path)
        @@bucket.objects[path].exists?
      end

      def write(path, options_or_data = nil, options = nil)
        @@bucket.objects[path].write(options_or_data, options)
      end

      private

      def options
        opts = {}
        opts[:access_key_id]     = OmniStore::Config.access_key if OmniStore::Config.access_key
        opts[:secret_access_key] = OmniStore::Config.secret_key if OmniStore::Config.secret_key
        opts[:s3_endpoint]       = OmniStore::Config.endpoint   if OmniStore::Config.endpoint
        opts[:proxy_uri]         = OmniStore::Config.proxy_uri  if OmniStore::Config.proxy_uri
        opts
      end
    end
  end
end
