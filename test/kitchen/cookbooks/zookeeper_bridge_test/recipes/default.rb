#
# Cookbook Name:: zookeeper_bridge_test
# Recipe:: default
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

include_recipe 'zookeeper::zookeeper'

zk_bin = "#{node[:zookeeper][:install_dir]}/zookeeper-#{node[:zookeeper][:version]}/bin"
service 'zookeeper' do
  restart_command "#{zk_bin}/zkServer.sh restart zoo_sample.cfg"
  start_command "#{zk_bin}/zkServer.sh start zoo_sample.cfg"
  status_command "#{zk_bin}/zkServer.sh status zoo_sample.cfg"
  stop_command "#{zk_bin}/zkServer.sh stop zoo_sample.cfg"
  action :start
end

include_recipe 'zookeeper_bridge'

# start clean up
zookeeper_bridge_cli 'create /test some_random_data'
zookeeper_bridge_cli 'delete /test/zookeeper_bridge'

# test created event
zookeeper_bridge_cli 'create /test/zookeeper_bridge more_random_data' do
  sleep 2
  background true
end
zookeeper_bridge_wait '/test/zookeeper_bridge' do
  status :created
  event :none
end

# test changed event
zookeeper_bridge_cli 'set /test/zookeeper_bridge update_random_data' do
  sleep 2
  background true
end
zookeeper_bridge_wait '/test/zookeeper_bridge' do
  status :any
  event :changed
end

# test deleted event
zookeeper_bridge_cli 'delete /test/zookeeper_bridge' do
  sleep 2
  background true
end
zookeeper_bridge_wait '/test/zookeeper_bridge' do
  status :deleted
  event :none
end

# test attributes write
zookeeper_bridge_attrs '/test/attributes' do
  attribute node['zookeeper']
  action :write
end

# test attributes read
zookeeper_bridge_attrs '/test/attributes' do
  attribute node.normal['zookeeper_read']
  action :read
end

ruby_block 'Attribute read test: ZooKeeper version' do
  block do
    raise unless node['zookeeper_read']['version'].kind_of?(String)
  end
end

# end clean up
zookeeper_bridge_cli 'delete /test/zookeeper_bridge'