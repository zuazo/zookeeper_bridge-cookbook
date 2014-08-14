# encoding: UTF-8

# Based on ZK gem examples:
#   https://github.com/zk-ruby/zk/blob/master/docs/examples

require 'json'
begin
  require 'zk'
rescue LoadError
  Chef::Log.info("Missing gem 'zk'")
end

class Chef
  # Chef helpers to interact with ZooKeeper
  class ZookeeperBridge
    class ZkHashFormatError < StandardError; end

    # Load the required dependencies
    class Depends
      def self.load
        unless defined?(ZK)
          Chef::Log.info('Trying to load "zk" gem at runtime.')
          Gem.clear_paths
          require 'zk'
        end
      end
    end

    private

    def force_encoding(o, encoding = 'UTF-8')
      case o
      when Hash
        o.each_with_object({}) do |(k, v), r|
          r[force_encoding(k, encoding)] = force_encoding(v, encoding)
        end
      when Array then o.map { |i| force_encoding(i, encoding) }
      when String then o.dup.force_encoding(encoding)
      else
        o
      end
    end

    def path_to_name_and_root_node(path)
      root_node = ::File.dirname(path)
      root_node = nil if root_node == '.'
      [root_node, ::File.basename(path)]
    end

    def zk_read_hash(path, encoding = nil, force = false)
      # TODO: raise differente exception for connection errors
      attrs, stat = @zk.get(path)
      attrs = force_encoding(attrs, encoding) unless encoding.nil?
      fail ZkHashFormatError unless attrs.is_a?(String)
      [JSON.parse(attrs), version: stat.version]
    rescue JSON::ParserError
      if force
        [{}, {}]
      else
        raise ZkHashFormatError
      end
    end

    def zk_write_hash(path, attrs, key = nil, encoding = nil)
      attrs = force_encoding(attrs, encoding) unless encoding.nil?
      attrs = { key => attrs } unless key.nil?
      @zk.create(path, attrs.to_json)
    end

    def zk_merge_hash(path, attrs, key = nil, encoding = nil)
      # TODO: test this hash merge properly
      attrs = force_encoding(attributes, encoding) unless encoding.nil?
      read_attrs, version = zk_read_hash(path, encoding, true)
      if !key.nil?
        return false if read_attrs[key] == attrs
        attrs = read_attrs[key].merge(attrs) if read_attrs.key?(key)
      else
        return false if read_attrs == attrs
        attrs = read_attrs.merge(attrs)
      end
      @zk.set(path, attrs.to_json, version)
    end

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
            yield(:created) # ooh! surprise! There it is!
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

    def initialize(server)
      Chef::ZookeeperBridge::Depends.load
      @zk = ZK.new(server)
    end

    def close
      @zk.close
    end

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

    # ZooKeeper blockers until desired state is met
    class StatusLocker < ZookeeperBridge
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

    # ZooKeeper logic to read/write node attributes
    class Attributes < ZookeeperBridge
      def read(path, attributes, key = nil, encoding = nil)
        attrs, _version = zk_read_hash(path, encoding, false)
        unless key.nil?
          return false unless attrs.key?(key)
          attrs = attrs[key] unless key.nil?
        end
        attributes.merge!(attrs)
        true
      rescue ZkHashFormatError
        false
      end

      def write(path, attributes, key = nil, encoding = nil)
        attributes = attributes.to_hash
        if @zk.exists?(path)
          zk_merge_hash(path, attributes, key, encoding)
        else
          zk_write_hash(path, attributes, key, encoding)
        end
      end
    end # Attributes
  end # ZookeeperBridge
end
