#!/usr/bin/env rake
$:.push File.expand_path("../lib", __FILE__)

require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require "omnistore/version"

task :default => :spec

RSpec::Core::RakeTask.new(:spec)
