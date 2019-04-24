module OmniStore
  module Storage
    extend self

    def storage
      remount! unless @storage
      @storage
    end

    def remount!
      unless OmniStore::Storage.const_defined?(camelcase(OmniStore::Config.storage))
        require "omnistore/storage/#{OmniStore::Config.storage}"
      end
      @storage = OmniStore::Storage.const_get(camelcase(OmniStore::Config.storage))
      @storage.mount!
    end

    private
    def camelcase(s)
      s.split('_').map{|e| e.capitalize }.join
    end
  end
end
