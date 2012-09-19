require 'omnistore/storage/local/mountpoint'

module OmniStore
  module Storage
    module Local
      extend self

      def mount!
        @@keys = {}
        case mountpoint = OmniStore::Config.mountpoint
        when Array
          mountpoint.each do |m|
            validate(m)
            @@keys[m] = {:name => File.basename(m), :dir => m}
          end
        when Hash
          mountpoint.each do |k,v|
            validate(v)
            @@keys[k] = {:name => k, :dir => v}
          end
        else
          m = mountpoint.to_s
          validate(m)
          @@keys[m] = {:name => File.basename(m), :dir => m}
        end
      end

      def mountpoint(key = @@keys.keys.first)
        new_mountpoint(key)
      end

      def exist?(path, mp = mountpoint)
        mp.exist?(path)
      end

      def delete(path, mp = mountpoint)
        mp.delete(path)
      end

      def read(path, options = {}, mp = mountpoint, &block)
        mp.read(path, options, &block)
      end

      def write(path, options_or_data = nil, options = {}, mp = mountpoint)
        mp.write(path, options_or_data, options)
      end

      def each(&block)
        if block_given?
          @@keys.each{|key| yield new_mountpoint(key) }
        else
          Enumerator.new(@@keys.map{|key| new_mountpoint(key) })
        end
      end

      private

      def validate(mountpoint)
        raise OmniStore::Errors::InvalidMountpoint unless File.exist?(mountpoint) && File.directory?(mountpoint)
      end

      def new_mountpoint(key)
        return nil unless @@keys.key?(key)
        Mountpoint.new(@@keys[key][:name], @@keys[key][:dir])
      end
    end
  end
end
