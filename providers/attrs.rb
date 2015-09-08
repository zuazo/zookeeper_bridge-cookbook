# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Provider:: attrs
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

def server
  new_resource.server || node['zookeeper_bridge']['server']
end

action :read do
  unless new_resource.attribute.is_a?(Chef::Node::VividMash)
    fail ArgumentError, 'wrong node attribute: you should use writable node '\
      'attributes like node.defaut[...] or node.normal[...].'
  end
  merge = new_resource.merge.nil? ? true : new_resource.merge
  zk_attrs = Chef::ZookeeperBridge::Attributes.new(server)
  new_resource.updated_by_last_action(
    zk_attrs.read(
      new_resource.path,
      new_resource.attribute,
      merge,
      new_resource.force_encoding
    )
  )
  zk_attrs.close
end

action :write do
  if new_resource.attribute.is_a?(Chef::Node) ||
     new_resource.attribute.is_a?(Chef::Node::Attribute)
    attribute = new_resource.attribute.merged_attributes
  else
    attribute = new_resource.attribute
  end
  unless attribute.is_a?(Chef::Node::ImmutableMash)
    fail ArgumentError,
         "Wrong node attribute (#{attribute.class.name}): you should use "\
         'readable node attributes like node[...].'
  end
  merge = new_resource.merge.nil? ? false : new_resource.merge
  zk_attrs = Chef::ZookeeperBridge::Attributes.new(server)
  new_resource.updated_by_last_action(
    zk_attrs.write(
      new_resource.path,
      attribute,
      merge,
      new_resource.force_encoding
    )
  )
  zk_attrs.close
end
