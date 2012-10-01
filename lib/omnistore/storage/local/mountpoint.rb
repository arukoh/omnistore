module OmniStore
  module Storage
    module Local
      class Mountpoint
        MEGABYTE = 1024*1024
        attr_reader :dir

        def initialize(name, dir)
          @name = name
          @dir  = dir
        end

        def name
          @name
        end

        def url(key = nil, options = {})
          "file://#{dir}/#{key}"
        end

        def exist?(path)
          File.exist?(expand(path))
        end

        def delete(path)
          FileUtils.rm(expand(path))
        end

        def delete_if(dir = '', &block)
          Dir.glob("#{expand(dir)}/**/*").each do |path|
            if yield(path)
              if File.directory?(path)
                FileUtils.rmdir(path)
              else
                FileUtils.rm(path)
              end
            end
          end
        end

        def read(path, options = {}, &block)
          size = options[:chunk_size] || MEGABYTE
          open(expand(path), 'rb') do |f|
            if block_given?
              block.call(f.read(size)) until f.eof?
            else
              f.read
            end
          end
        end

        def write(path, options_or_data = nil, options = {})
          opts = convert_args_to_options_hash(options_or_data, options)
          size = opts[:chunk_size] || MEGABYTE
          data = convert_data_to_io_obj(opts)
          begin
            open(expand(path), 'wb') do |f|
              f.write(data.read(size)) until data.eof?
            end
          ensure
            data.close unless data.closed?
          end
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
        
        def convert_args_to_options_hash(*args)
          case args.count
          when 0 then {}
          when 1 then args[0].is_a?(Hash) ? args[0] : { :data => args[0] }
          when 2 then args[1].merge(:data => args[0])
          else
            msg = "expected 0, 1 or 2 arguments, got #{args.count}"
            raise ArgumentError, msg
          end
        end

        def convert_data_to_io_obj(options)
          data = options.delete(:data)
          if data.is_a?(String)
            data.force_encoding("BINARY") if data.respond_to?(:force_encoding)
            StringIO.new(data)
          elsif data.is_a?(Pathname)
            open_file(data.to_s)
          elsif data.respond_to?(:read) and data.respond_to?(:eof?)
            data
          else
            msg = "invalid :data option, expected a String, Pathname or "
            msg << "an object that responds to #read and #eof?"
            raise ArgumentError, msg
          end
        end

        def open_file(path)
          file_opts = ['rb']
          file_opts << { :encoding => "BINARY" } if Object.const_defined?(:Encoding)
          File.open(path, *file_opts)
        end
      end
    end
  end
end


