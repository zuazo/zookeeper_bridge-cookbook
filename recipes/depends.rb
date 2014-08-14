# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Recipe:: depends
#
# Copyright 2013, Onddo Labs, Sl.
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

node.default['build-essential']['compiletime'] = true
include_recipe 'build-essential'

chef_gem 'zk' # not required in zookeeper_handler recipe, but does not harm
chef_gem 'chef-handler-zookeeper' do
  version node['zookeeper_bridge']['chef_handler']['version']
end
