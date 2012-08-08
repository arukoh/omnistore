require 'aws-sdk'

module OmniStore
  module Storage
    module S3
      extend self

      class Mountpoint
        attr_reader :bucket

        def initialize(bucket)
          @bucket = bucket
        end

        def exist?(key)
          bucket.objects[key].exists?
        end

        def delete(key, options = {})
          bucket.objects[key].delete(options)
        end

        def write(key, options_or_data = nil, options = nil)
          bucket.objects[key].write(options_or_data, options)
        end
      end

      def mount!
        @@buckets = {}
        case mountpoint = OmniStore::Config.mountpoint
        when Array then mountpoint.each {|m| b = validate(m); @@buckets[m] = Mountpoint.new(b) }
        when Hash  then mountpoint.each {|k,v| b = validate(v); @@buckets[k] = Mountpoint.new(b) }
        else m = mountpoint.to_s; b = validate(m); @@buckets[m] = Mountpoint.new(b)
        end
      end

      def mountpoint(key)
        @@buckets[key]
      end

      def exist?(path)
        @@buckets.values.find {|b| b.exist?(path) }
      end
      alias :find :exist?

      def delete(path, options = {})
        @@buckets.values.each {|b| b.delete(path, options) }
      end

      def write(path, options_or_data = nil, options = nil)
        @@buckets.values.each {|b| b.write(path, options_or_data, options) }
      end

      private

      def validate(name)
        bucket = AWS::S3.new(options).buckets[name]
        raise OmniStore::Errors::InvalidMountpoint unless bucket.exists?
        bucket
      end

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
