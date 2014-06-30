#
# Cookbook Name:: zookeeper-bridge
# Recipe:: zookeeper_handler
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

# Notice: include this recipe near the beginning of the node's run list so
# that the start handler can take effect early on.

include_recipe 'zookeeper-bridge::depends'

# Handler configuration options
argument_array = [
  :server => node['zookeeper-bridge']['zookeeper']['server'].to_s,
  :znode => "/chef/#{`hostname`.chomp}/status",
]

# Install the `chef-handler-zookeeper` RubyGem during the compile phase
if defined?(Chef::Resource::ChefGem)
  chef_gem 'chef-handler-zookeeper' do
    version node['zookeeper-bridge']['zookeeper-handler']['version']
  end
else
  gem_package('chef-handler-zookeeper') do
    version node['zookeeper-bridge']['zookeeper-handler']['version']
    action :nothing
  end.run_action(:install)
end

zookeeper_handler_path = Gem::Specification.respond_to?('find_by_name') ?
  Gem::Specification.find_by_name('chef-handler-zookeeper').lib_dirs_glob :
  Gem.all_load_paths.grep(/chef-handler-zookeeper/).first

# Then activate the handler with the `chef_handler` LWRP
chef_handler "Chef::Handler::ZookeeperHandler" do
  source "#{zookeeper_handler_path}/chef/handler/zookeeper"
  arguments argument_array
  supports :start => true, :report => true, :exception => true
  action :nothing
end.run_action(:enable)

# based on code from chef-sensu-handler cookbook
ruby_block 'trigger_start_handlers' do
  block do
    require 'chef/run_status'
    require 'chef/handler'

    # a bit tricky, required by the default start.json.erb template to have access to node
    Chef::Handler.run_start_handlers(self)
  end
  action :nothing
end.run_action(:create)

