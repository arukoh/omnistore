module OmniStore
  module Storage
    module Local
      extend self

      @@mountpoint = nil

      def mount!
        mountpoint = OmniStore::Config.mountpoint.to_s
        raise OmniStore::Errors::InvalidMountpoint unless File.exist?(mountpoint) && File.directory?(mountpoint)
        @@mountpoint = mountpoint
      end

      def exist?(path)
        File.exist?(File.join(@@mountpoint, path))
      end
    end
  end
end
