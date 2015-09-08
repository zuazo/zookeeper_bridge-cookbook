# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Library:: zookeeper_bridge_locker
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

class Chef
  class ZookeeperBridge
    # ZooKeeper different locks logic
    class Locker < ZookeeperBridge
      private

      def lock_wait_with_class(klass, path, wait, args = [], block)
        root_node, name = path_to_name_and_root_node(path)
        args = [@zk, name, args, root_node].flatten.compact
        lock = klass.send(:new, *args)
        lock.with_lock(wait: wait) do
          Chef::Log.debug(
            "Zookeeper Bridge #{caller[0].to_s.tr('_', ' ')} in \"#{path}\""
          )
          block.call
        end
      end

      public

      def shared_lock(path, wait, &blk)
        lock_wait_with_class(ZK::Locker::SharedLocker, path, wait, nil, blk)
      end

      def exclusive_lock(path, wait, &blk)
        lock_wait_with_class(ZK::Locker::ExclusiveLocker, path, wait, nil, blk)
      end

      def semaphore(path, size, wait, &blk)
        lock_wait_with_class(ZK::Locker::Semaphore, path, wait, size, blk)
      end
    end # Locker
  end # ZookeeperBridge
end
