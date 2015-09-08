# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Provider:: wrlock
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

def whyrun_supported?
  true
end

def server
  new_resource.server || node['zookeeper_bridge']['server']
end

action :run do
  converge_by("run #{new_resource}") do
    zk_locker = Chef::ZookeeperBridge::Locker.new(server)
    zk_locker.exclusive_lock(new_resource.path, new_resource.wait) do
      recipe_eval(&new_resource.block)
    end
    zk_locker.close
  end
end
