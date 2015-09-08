# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Library:: zookeeper_bridge_attributes
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

class Chef
  class ZookeeperBridge
    # ZooKeeper logic to read/write node attributes
    class Attributes < ZookeeperBridge
      private

      def hash_merge(onto, with)
        Chef::Mixin::DeepMerge.hash_only_merge(onto, with)
      end

      def hash_merge!(onto, with)
        Chef::Mixin::DeepMerge.hash_only_merge!(onto, with)
      end

      def zk_exist?(path)
        @zk.exists?(path)
      end

      def zk_get_hash(path, encoding = nil, force = false)
        # TODO: raise different exceptions for connection errors
        attrs, stat = @zk.get(path)
        attrs = force_encoding(attrs, encoding) unless encoding.nil?
        fail ZkHashFormatError unless attrs.is_a?(String)
        [JSON.parse(attrs), version: stat.version]
      rescue JSON::ParserError
        if force
          [{}, {}]
        else
          raise ZkHashFormatError
        end
      end

      def zk_create_hash(path, attrs, encoding = nil)
        attrs = force_encoding(attrs, encoding) unless encoding.nil?
        !@zk.create(path, attrs.to_json).nil?
      end

      def zk_set_hash(path, attrs, merge, encoding = nil)
        attrs = force_encoding(attrs, encoding) unless encoding.nil?
        orig_attrs, ver = zk_get_hash(path, encoding, true)
        attrs = hash_merge(orig_attrs, attrs) if merge
        orig_attrs != attrs ? !@zk.set(path, attrs.to_json, ver).nil? : false
      end

      public

      def read(path, attributes, merge, encoding = nil)
        attrs, _version = zk_get_hash(path, encoding, false)
        merge ? hash_merge!(attributes, attrs) : attributes.replace(attrs)
        true
      rescue ZkHashFormatError
        false
      end

      def write(path, attributes, merge, encoding = nil)
        attributes = attributes.to_hash
        if zk_exist?(path)
          zk_set_hash(path, attributes, merge, encoding)
        else
          zk_create_hash(path, attributes, encoding)
        end
      end
    end # Attributes
  end # ZookeeperBridge
end
