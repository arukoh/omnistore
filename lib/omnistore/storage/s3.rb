require 'aws-sdk'

module OmniStore
  module Storage
    module S3
      extend self

      class Mountpoint
        attr_reader :bucket

        def initialize(name, bucket)
          @name   = name
          @bucket = bucket
        end

        def name
          @name
        end

        def url
          bucket.url
        end

        def exist?(key)
          bucket.objects[key].exists?
        end

        def delete(key, options = {})
          bucket.objects[key].delete(options)
        end

        def write(key, options_or_data = nil, options = {})
          bucket.objects[key].write(options_or_data, options)
        end

        def move(src, dest, other = self, options = {})
          options[:bucket_name] = other.bucket.name
          bucket.objects[key].move_to(dest, options)
        end
      end

      def mount!
        @@buckets = {}
        case mountpoint = OmniStore::Config.mountpoint
        when Array then mountpoint.each {|m| b = validate(m); @@buckets[m] = Mountpoint.new(m, b) }
        when Hash  then mountpoint.each {|k,v| b = validate(v); @@buckets[k] = Mountpoint.new(k, b) }
        else m = mountpoint.to_s; b = validate(m); @@buckets[m] = Mountpoint.new(m, b)
        end
      end

      def mountpoint(key = @@buckets.keys[0])
        @@buckets[key]
      end

      def exist?(path, mp = mountpoint)
        mp.exist?(path)
      end
      alias :find :exist?

      def delete(path, options = {}, mp = mountpoint)
        mp.delete(path, options)
      end

      def write(path, options_or_data = nil, options = {}, mp = mountpoint)
        mp.write(path, options_or_data, options)
      end

      def each(&block)
        if block_given?
          @@buckets.each{|b| yield b }
        else
          Enumerator.new(@@buckets.values)
        end
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
