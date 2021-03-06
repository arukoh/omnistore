module OmniStore
  module Storage
    module S3
      class Mountpoint
        attr_reader :bucket

        def initialize(name, bucket)
          @name   = name
          @bucket = bucket
        end

        def name
          @name
        end

        def url(key = nil, options = {})
          if key
            bucket.objects[key].public_url(:secure => options[:secure] != false).to_s
          else
            bucket.url
          end
        end

        def exist?(key)
          bucket.objects[key].exists?
        end

        def delete(key, options = {})
          bucket.objects[key].delete(options)
        end

        def delete_if(key_prefix = nil, &block)
          bucket.objects.with_prefix(key_prefix).delete_if do |object|
            yield object.key
          end
        end

        def read(key, options = {}, &block)
          bucket.objects[key].read(options, &block)
        end

        def write(key, options_or_data = nil, options = {})
          bucket.objects[key].write(options_or_data, options)
        end

        def move(src, dest, other = self, options = {})
          options[:bucket_name] = other.bucket.name
          bucket.objects[src].move_to(dest, options)
        end

        def copy(src, dest, other = self, options = {})
          options[:bucket] = other.bucket
          bucket.objects[src].copy_to(dest, options)
        end
      end
    end
  end
end
