# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Library:: zookeeper_bridge_attributes
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL. (www.onddo.com)
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

      def zk_read_hash(path, encoding = nil, force = false)
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

      def zk_write_hash(path, attrs, key = nil, encoding = nil)
        attrs = force_encoding(attrs, encoding) unless encoding.nil?
        attrs = { key => attrs } unless key.nil?
        !@zk.create(path, attrs.to_json).nil?
      end

      def zk_merge_hash(path, attrs, key = nil, encoding = nil)
        attrs = force_encoding(attributes, encoding) unless encoding.nil?
        orig_attrs, ver = zk_read_hash(path, encoding, true)
        if !key.nil?
          attrs = hash_merge(orig_attrs[key], attrs) if orig_attrs.key?(key)
        else
          attrs = hash_merge(orig_attrs, attrs)
        end
        orig_attrs != attrs ? !@zk.set(path, attrs.to_json, ver).nil? : false
      end

      public

      def read(path, attributes, key = nil, encoding = nil)
        attrs, _version = zk_read_hash(path, encoding, false)
        unless key.nil?
          return false unless attrs.key?(key)
          attrs = attrs[key] unless key.nil?
        end
        hash_merge!(attributes, attrs)
        true
      rescue ZkHashFormatError
        false
      end

      def write(path, attributes, key = nil, encoding = nil)
        attributes = attributes.to_hash
        if @zk.exists?(path) # TODO: we rly need a merge here?
          zk_merge_hash(path, attributes, key, encoding)
        else
          zk_write_hash(path, attributes, key, encoding)
        end
      end
    end # Attributes
  end # ZookeeperBridge
end
