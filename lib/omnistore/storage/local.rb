module OmniStore
  module Storage
    module Local
      extend self

      class Mountpoint
        attr_reader :dir

        def initialize(dir)
          @dir = dir
        end

        def exist?(path)
          File.exist?(expand(path))
        end

        def delete(path)
          FileUtils.rm(expand(path))
        end

        def move(src, dest, other = self, options = {})
          src_path = expand(src)
          dest_path = expand(dest, other.dir)
          FileUtils.mv(src_path, dest_path, options)
        end

        private

        def expand(path, dir = @dir)
          File.expand_path(path, dir)
        end
      end

      def mount!
        @@mountpoint = {}
        case mountpoint = OmniStore::Config.mountpoint
        when Array then mountpoint.each {|m| validate(m); @@mountpoint[m] = Mountpoint.new(m) }
        when Hash  then mountpoint.each {|k,v| validate(v); @@mountpoint[k] = Mountpoint.new(v) }
        else m = mountpoint.to_s; validate(m); @@mountpoint[m] = Mountpoint.new(m)
        end
      end

      def mountpoint(key)
        @@mountpoint[key]
      end

      def exist?(path)
        @@mountpoint.values.find {|m| m.exist?(path) }
      end

      def delete(path)
        @@mountpoint.values.each {|m| m.delete(path) }
      end

      private

      def validate(mountpoint)
        raise OmniStore::Errors::InvalidMountpoint unless File.exist?(mountpoint) && File.directory?(mountpoint)
      end
    end
  end
end
