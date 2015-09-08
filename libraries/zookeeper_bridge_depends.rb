# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Library:: zookeeper_bridge_depends
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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
