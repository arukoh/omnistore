module OmniStore
  module Storage
    module Local
      extend self

      class Mountpoint
        attr_reader :dir

        def initialize(name, dir)
          @name = name
          @dir  = dir
        end

        def name
          @name
        end

        def url
          "file://#{dir}"
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
          FileUtils.mkdir_p(File.dirname(dest_path)) if options[:force]
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
        when Array then mountpoint.each {|m| validate(m); @@mountpoint[m] = Mountpoint.new(File.basename(m), m) }
        when Hash  then mountpoint.each {|k,v| validate(v); @@mountpoint[k] = Mountpoint.new(k, v) }
        else m = mountpoint.to_s; validate(m); @@mountpoint[m] = Mountpoint.new(File.basename(m), m)
        end
      end

      def mountpoint(key = @@mountpoint.keys[0])
        @@mountpoint[key]
      end

      def exist?(path, mp = mountpoint)
        mp.exist?(path)
      end

      def delete(path, mp = mountpoint)
        mp.delete(path)
      end

      def each(&block)
        if block_given?
          @@mountpoint.each{|m| yield m }
        else
          Enumerator.new(@@mountpoint.values)
        end
      end

      private

      def validate(mountpoint)
        raise OmniStore::Errors::InvalidMountpoint unless File.exist?(mountpoint) && File.directory?(mountpoint)
      end
    end
  end
end
