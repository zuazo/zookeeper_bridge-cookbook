# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Provider:: cli
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

def base_path
  new_resource.base_path(
    if new_resource.base_path.nil?
      ::File.join(
        node['zookeeper']['install_dir'],
        "zookeeper-#{node['zookeeper']['version']}"
      )
    else
      new_resource.base_path
    end
  )
end

action :run do
  # TODO: a bit tricky
  command = new_resource.command.gsub(/\\/, '\\\\').gsub(/"/, '\\"')
  cli = ::File.join(base_path, 'bin', 'zkCli.sh')
  sleep_prefix =
    if new_resource.sleep && new_resource.sleep > 0
      "sleep '#{new_resource.sleep}' && "
    else
      ''
    end
  background_sufix = new_resource.background ? ' &' : ''

  converge_by("Run zookeeper client command: #{command}") do
    execute "#{sleep_prefix}echo \"#{command}\" | '#{cli}'#{background_sufix}"
    # TODO: raise an exception if the zk command throws an error
  end
end
