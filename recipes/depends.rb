# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Recipe:: depends
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

package 'tar' do
  action :install
end.run_action(:install)

include_recipe 'build-essential'

chef_gem 'zk' # not required in zookeeper_handler recipe, but does not harm

# Install the `chef-handler-zookeeper` RubyGem during the compile phase
if defined?(Chef::Resource::ChefGem)
  chef_gem 'chef-handler-zookeeper' do
    version node['zookeeper_bridge']['chef_handler']['version']
  end
else
  gem_package('chef-handler-zookeeper') do
    version node['zookeeper_bridge']['chef_handler']['version']
    action :nothing
  end.run_action(:install)
end
