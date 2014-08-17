# encoding: UTF-8

class Chef
  class ZookeeperBridge
    # ZooKeeper different locks logic
    class Locker < ZookeeperBridge
      def shared_lock(path, wait)
        root_node, name = path_to_name_and_root_node(path)
        lock = ZK::Locker::SharedLocker.new(@zk, name, root_node)
        lock.with_lock(wait: wait) do
          Chef::Log.debug(
            "Zookeeper Bridge #{__method__.to_s.gsub('_', ' ')} in \"#{path}\""
          )
          yield
        end
      end

      def exclusive_lock(path, wait)
        root_node, name = path_to_name_and_root_node(path)
        lock = ZK::Locker::ExclusiveLocker.new(@zk, name, root_node)
        lock.with_lock(wait: wait) do
          Chef::Log.debug(
            "Zookeeper Bridge #{__method__.to_s.gsub('_', ' ')} in \"#{path}\""
          )
          yield
        end
      end

      def semaphore(path, size, wait)
        root_node, name = path_to_name_and_root_node(path)
        lock = ZK::Locker::Semaphore.new(@zk, name, size, root_node)
        lock.with_lock(wait: wait) do
          Chef::Log.debug(
            "Zookeeper Bridge #{__method__.to_s.gsub('_', ' ')} in \"#{path}\""
          )
          yield
        end
      end
    end # Locker
  end # ZookeeperBridge
end
