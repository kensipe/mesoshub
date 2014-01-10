require "rubygems"
require "bundler/setup"
require "zk"
require "json"
require "open-uri"
require "sinatra"

__LIB_DIR__ = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift __LIB_DIR__ unless $LOAD_PATH.include?(__LIB_DIR__)

require 'mesoshub/version'
require 'mesoshub/haproxy_config'
require 'mesoshub/zookeeper'
require 'mesoshub/marathon'
require 'mesoshub/webapp'

module Mesoshub
end
