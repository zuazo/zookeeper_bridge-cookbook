# encoding: UTF-8

class Chef
  class ZookeeperBridge
    # ZooKeeper lockers until the desired state is met
    class StatusLocker < ZookeeperBridge
      private

      def event_types_hash(event_types)
        event_types_ary = [event_types].flatten
        event_types_ary.each_with_object({}) do |v, r|
          r["ZOO_#{v.to_s.upcase}_EVENT"] = v.to_sym
        end
      end

      def subscribe_until_event(path, event_types)
        event_types_hs = event_types_hash(event_types)
        @zk.register(path) do |event|
          yield(event_types_hs[event]) if event_types_hs.key?(event.event_name)
        end
      end

      def subscribe_until_created(path)
        @zk.register(path) do |event|
          if event.node_created?
            yield(:created)
          else
            if @zk.exists?(event.path, watch: true)
              yield(:created) # ooh! surprise! there it is!
            end
          end
        end
      end

      def subscribe_until_deleted(path)
        @zk.register(path) do |event|
          if event.node_deleted?
            yield(:deleted)
          else
            unless @zk.exists?(event.path, watch:  true)
              yield(:deleted) # ooh! surprise! it's gone!
            end
          end
        end
      end

      public

      def until_znode_event(path, events)
        queue = Queue.new
        ev_sub = subscribe_until_event(path, events) { |e| queue.enq(e) }
        @zk.stat(path, watch: true)
        queue.pop # block waiting for node change
      ensure
        ev_sub.unsubscribe unless ev_sub.nil?
      end

      def until_znode_created(path)
        queue = Queue.new
        ev_sub = subscribe_until_created(path) { |e| queue.enq(e) }
        # set up the callback, but bail if we don't need to wait
        return true if @zk.exists?(path, watch:  true)
        queue.pop # block waiting for node creation
      ensure
        ev_sub.unsubscribe unless ev_sub.nil?
      end

      def until_znode_changed(path)
        block_until_znode_event(path, :changed)
      end

      def until_znode_deleted(path)
        queue = Queue.new
        ev_sub = subscribe_until_deleted(path) { |e| queue.enq(e) }
        # set up the callback, but bail if we don't need to wait
        return true unless @zk.exists?(path, watch:  true)
        queue.pop # block waiting for node deletion
      ensure
        ev_sub.unsubscribe unless ev_sub.nil?
      end
    end # StatusLocker
  end # ZookeeperBridge
end
