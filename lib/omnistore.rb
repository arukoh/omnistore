require 'logger'
require 'active_support/inflector'
require "omnistore/version"
require 'omnistore/config'
require 'omnistore/errors'
require 'omnistore/storage'

module OmniStore
  extend self

  def configure
    block_given? ? yield(OmniStore::Config) : OmniStore::Config
    OmniStore::Storage.remount!
  end
  alias :config :configure

  def logger
    OmniStore::Config.logger
  end

end
