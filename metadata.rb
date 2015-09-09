# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
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

name 'zookeeper_bridge'
maintainer 'Xabier de Zuazo'
maintainer_email 'xabier@zuazo.org'
license 'Apache 2.0'
description 'Cookbook used to help integrating the Chef Run with ZooKeeper: '\
  'chef handler, locks, semaphores, ...'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.3.0'

if respond_to?(:source_url)
  source_url "https://github.com/zuazo/#{name}-cookbook"
end
if respond_to?(:issues_url)
  issues_url "https://github.com/zuazo/#{name}-cookbook/issues"
end

supports 'amazon'
supports 'centos'
supports 'debian'
supports 'ubuntu'

depends 'build-essential', '~> 2.0'
depends 'chef_handler'

recipe 'zookeeper_bridge::default',
       'Recipe required before using the resources.'
recipe 'zookeeper_bridge::chef_handler',
       'Installs and enables chef-handler-zookeeper.'
recipe 'zookeeper_bridge::depends',
       'Install some dependencies required by this cookbooks. Used by the '\
       'other recipes.'

attribute 'zookeeper_bridge/server',
          display_name: 'zookeeper server',
          description: 'Zookeeper server address.',
          type: 'string',
          required: 'optional',
          default: '"127.0.0.1:2181"'

attribute 'zookeeper_bridge/chef_handler/version',
          display_name: 'zookeeper handler version',
          description: 'chef-handler-zookeeper gem version to install.',
          type: 'string',
          required: 'optional',
          default: 'nil'

attribute 'zookeeper_bridge/chef_handler/znode',
          display_name: 'zookeeper handler znode',
          description: 'chef-handler-zookeeper znode path.',
          type: 'string',
          required: 'optional',
          default: '"/chef/#{node[\'fqdn\']}/status"'

provides 'zookeeper_bridge_attrs'
provides 'zookeeper_bridge_cli'
provides 'zookeeper_bridge_rdlock'
provides 'zookeeper_bridge_sem'
provides 'zookeeper_bridge_wait'
provides 'zookeeper_bridge_wrlock'
