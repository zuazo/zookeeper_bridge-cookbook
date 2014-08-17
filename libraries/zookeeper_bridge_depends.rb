# encoding: UTF-8

require 'json'
begin
  require 'zk'
rescue LoadError
  Chef::Log.info("Missing gem 'zk'")
end

class Chef
  class ZookeeperBridge
    # Load the required dependencies
    class Depends
      def self.load
        unless defined?(ZK)
          Chef::Log.info('Trying to load "zk" gem at runtime.')
          Gem.clear_paths
          require 'zk'
        end
      end
    end # Depends
  end # ZookeeperBridge
end
