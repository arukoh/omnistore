#!/usr/bin/env rake
$:.push File.expand_path("../lib", __FILE__)

require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require "omnistore/version"

task :default => :spec

RSpec::Core::RakeTask.new(:spec)
