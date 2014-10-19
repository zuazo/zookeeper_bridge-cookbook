# encoding: UTF-8

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
            "Zookeeper Bridge #{caller[0].to_s.gsub('_', ' ')} in \"#{path}\""
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
