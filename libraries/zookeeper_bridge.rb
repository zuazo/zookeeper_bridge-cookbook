# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Library:: zookeeper_bridge
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

# Based on ZK gem examples:
#   https://github.com/zk-ruby/zk/blob/master/docs/examples

class Chef
  # Chef helpers to interact with ZooKeeper
  class ZookeeperBridge
    class ZkHashFormatError < StandardError; end

    private

    def force_encoding(o, encoding = 'UTF-8')
      case o
      when Hash
        o.each_with_object({}) do |(k, v), r|
          r[force_encoding(k, encoding)] = force_encoding(v, encoding)
        end
      when Array then o.map { |i| force_encoding(i, encoding) }
      when String then o.dup.force_encoding(encoding)
      else
        o
      end
    end

    public

    def initialize(server)
      Chef::ZookeeperBridge::Depends.load
      @zk = ZK.new(server)
    end

    # TODO: avoid #dirname & #basename to support non-unix platforms
    def path_to_name_and_root_node(path)
      path = path.gsub(%r{/*$}, '')
      result = []
      result[0] = path[0] == '/' ? ::File.dirname(path) : nil
      result[0] = nil if result[0] == '.'
      result[1] = result[0].nil? ? path : ::File.basename(path)
      result
    end

    def close
      @zk.close
    end
  end # ZookeeperBridge
end
