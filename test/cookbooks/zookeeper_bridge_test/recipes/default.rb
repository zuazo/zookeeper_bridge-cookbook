# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge_test
# Recipe:: default
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

def recipe_block_run(&block)
  @run_context.resource_collection = Chef::ResourceCollection.new
  instance_eval(&block)
  Chef::Runner.new(@run_context).converge
end

def recipe_fork(description, &block)
  recipe = self
  block_body = proc do
    fork { recipe_block_run(&block) }
  end
  ruby_block "recipe_fork[#{description}]" do
    block do
      recipe.instance_eval(&block_body)
    end
  end
end

forked_recipe_sleep = 3

node.default['zookeeper']['service_style'] = 'runit'
include_recipe 'zookeeper::default'
include_recipe 'runit'
include_recipe 'zookeeper::service'

include_recipe 'zookeeper_bridge'

# start clean up
zookeeper_bridge_cli 'create /test some_random_data'
zookeeper_bridge_cli 'delete /test/zookeeper_bridge'
zookeeper_bridge_cli 'delete /_zklocking'
zookeeper_bridge_cli 'delete /_zksemaphore'

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

#########
# Attrs #
#########

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
    fail unless node['zookeeper_read']['version'].is_a?(String)
  end
end

##############
# Read Locks #
##############

zookeeper_bridge_rdlock 'r001' do
  block do
    execute 'true'
  end
end

t1 = nil
ruby_block 'r002 t1' do
  block do
    t1 = Time.now
  end
end

recipe_fork 'r002 non-blocking read lock' do
  zookeeper_bridge_rdlock 'r002 1' do
    path 'r002'
    block do
      sleep(forked_recipe_sleep)
    end
  end
end

execute 'sleep 1'

zookeeper_bridge_rdlock 'r002 2' do
  path 'r002'
  block do
    execute 'true'
  end
end

ruby_block 'r002 t2' do
  block do
    t2 = Time.now
    if t2 - t1 > forked_recipe_sleep
      fail "r002 read lock blocked time wrong: #{(t2 - t1).round(2)}"
    end
  end
end

###############
# Write Locks #
###############

zookeeper_bridge_wrlock 'w001' do
  block do
    execute 'true'
  end
end

t1 = nil
ruby_block 'w002 t1' do
  block do
    t1 = Time.now
  end
end

recipe_fork 'w002 blocking write lock' do
  zookeeper_bridge_wrlock 'w002 wr1' do
    path 'w002'
    block do
      sleep(forked_recipe_sleep)
    end
  end
end

execute 'sleep 1'

zookeeper_bridge_wrlock 'w002 wr2' do
  path 'w002'
  block do
    execute 'true'
  end
end

ruby_block 'w002 t2' do
  block do
    t2 = Time.now
    if t2 - t1 < forked_recipe_sleep
      fail "w002 write lock blocked time wrong: #{(t2 - t1).round(2)}"
    end
  end
end

####################
# Read/Write Locks #
####################

# Read lock when write locked:
# 1. write lock
# 2. read lock

t1 = nil
ruby_block 'rw001 t1' do
  block do
    t1 = Time.now
  end
end

recipe_fork 'rw001 blocking write lock' do
  zookeeper_bridge_wrlock 'rw001 w1' do
    path 'rw001'
    block do
      sleep(forked_recipe_sleep)
    end
  end
end

execute 'sleep 1'

zookeeper_bridge_rdlock 'rw001 r1' do
  path 'rw001'
  block do
    execute 'true'
  end
end

ruby_block 'rw001 t2' do
  block do
    t2 = Time.now
    if t2 - t1 < forked_recipe_sleep
      fail "rw001 write/read lock blocked time wrong: #{(t2 - t1).round(2)}"
    end
  end
end

# Write lock when read locked:
# 1. read lock
# 2. write lock

t1 = nil
ruby_block 'rw002 t1' do
  block do
    t1 = Time.now
  end
end

recipe_fork 'rw002 write blocking read lock' do
  zookeeper_bridge_rdlock 'rw002 r1' do
    path 'rw002'
    block do
      sleep(forked_recipe_sleep)
    end
  end
end

execute 'sleep 1'

zookeeper_bridge_wrlock 'rw002 2' do
  path 'rw002'
  block do
    execute 'true'
  end
end

ruby_block 'rw002 t2' do
  block do
    t2 = Time.now
    if t2 - t1 < forked_recipe_sleep
      fail "rw002 read/write lock blocked time wrong: #{(t2 - t1).round(2)}"
    end
  end
end

##############
# Semaphores #
##############

zookeeper_bridge_sem 'sem001' do
  size 1
  block do
    execute 'true'
  end
end

sem_size = 1

t1 = nil
ruby_block 'sem002 t1' do
  block do
    t1 = Time.now
  end
end

recipe_fork 'sem002 blocking semaphore' do
  zookeeper_bridge_sem 'sem002 1' do
    path 'sem002'
    size sem_size
    block do
      sleep(forked_recipe_sleep)
    end
  end
end

execute 'sleep 1'

zookeeper_bridge_sem 'sem002 2' do
  path 'sem002'
  size sem_size
  block do
    execute 'true'
  end
end

ruby_block 'sem002 t2' do
  block do
    t2 = Time.now
    if t2 - t1 < forked_recipe_sleep
      fail "sem002 semaphore blocked time wrong: #{(t2 - t1).round(2)}"
    end
  end
end

# end clean up
zookeeper_bridge_cli 'delete /test/zookeeper_bridge'
zookeeper_bridge_cli 'delete /_zklocking'
zookeeper_bridge_cli 'delete /_zksemaphore'
