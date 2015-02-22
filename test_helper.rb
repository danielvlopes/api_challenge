ENV["RACK_ENV"] = "test"

require 'bundler'
Bundler.require :default, :test

require 'minitest/autorun'
require 'json'

require_relative './api'
