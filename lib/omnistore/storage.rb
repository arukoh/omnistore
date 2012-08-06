module OmniStore
  module Storage
    extend self

    def storage
      remount! unless @storage
      @storage
    end

    def remount!
      unless OmniStore::Storage.const_defined?(OmniStore::Config.storage.camelcase)
        require "omnistore/storage/#{OmniStore::Config.storage}"
      end
      @storage = OmniStore::Storage.const_get(OmniStore::Config.storage.camelcase)
      @storage.mount!
    end

  end
end
