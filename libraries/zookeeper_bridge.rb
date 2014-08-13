require 'json'
begin
  require 'zk'
rescue LoadError
  Chef::Log.info("Missing gem 'zk'")
end

class Chef
  # Chef helpers to interact with ZooKeeper
  class ZookeeperBridge
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
      name = ::File.basename(path)
      root_node = ::File.dirname(path)
      root_node = nil if root_node == '.'

      [root_node, name]
    end

    def event_types_hash(event_types)
      event_types_ary = [event_types].flatten
      event_types_ary.each_with_object({}) do |v, r|
        r["ZOO_#{v.to_s.upcase}_EVENT"] = v.to_sym
      end
    end

    public

    def initialize(server)
      Chef::ZookeeperBridge::Depends.load
      @zk = ZK.new(server)
    end

    # Based on ZK gem examples:
    #   https://github.com/zk-ruby/zk/blob/master/docs/examples

    def block_until_znode_event(abs_node_path, event_types)
      queue = Queue.new
      event_types_hs = event_types_hash(event_types)
      ev_sub = @zk.register(abs_node_path) do |event|
        if event_types_hs.key?(event.event_name)
          queue.enq(event_types_hs[event.event_name])
        end
      end
      @zk.stat(abs_node_path, watch: true)
      queue.pop # block waiting for node change
    ensure
      ev_sub.unsubscribe unless ev_sub.nil?
    end

    def block_until_znode_created(abs_node_path)
      queue = Queue.new

      ev_sub = @zk.register(abs_node_path) do |event|
        if event.node_created?
          queue.enq(:created)
        else
          if @zk.exists?(abs_node_path, watch: true)
            queue.enq(:created) # ooh! surprise! There it is!
          end
        end
      end

      # set up the callback, but bail if we don't need to wait
      return true if @zk.exists?(abs_node_path, watch:  true)

      queue.pop # block waiting for node creation
      true
    ensure
      ev_sub.unsubscribe unless ev_sub.nil?
    end

    def block_until_znode_changed(abs_node_path)
      block_until_znode_event(abs_node_path, :changed)
      true
    end

    def block_until_znode_deleted(abs_node_path)
      queue = Queue.new

      ev_sub = @zk.register(abs_node_path) do |event|
        if event.node_deleted?
          queue.enq(:deleted)
        else
          unless @zk.exists?(abs_node_path, watch:  true)
            # ooh! surprise! it's gone!
            queue.enq(:deleted)
          end
        end
      end

      # set up the callback, but bail if we don't need to wait
      return true unless @zk.exists?(abs_node_path, watch:  true)

      queue.pop # block waiting for node deletion
      true
    ensure
      ev_sub.unsubscribe unless ev_sub.nil?
    end

    def attributes_read(abs_node_path, attributes, key = nil, encoding = nil)
      attrs, _stat = @zk.get(abs_node_path)
      attrs = force_encoding(attrs, encoding) unless encoding.nil?
      if attrs.is_a?(String)
        attrs = JSON.parse(attrs)
        unless key.nil?
          return false unless attrs.key?(key)
          attrs = attrs[key] unless key.nil?
        end
        attributes.merge!(attrs)
        return true
      end
      false
    end

    def attributes_write(abs_node_path, attributes, key = nil, encoding = nil)
      attributes = attributes.to_hash
      attributes = force_encoding(attributes, encoding) unless encoding.nil?
      if @zk.exists?(abs_node_path)
        # TODO: test this hash merge properly
        read_data, stat = @zk.get(abs_node_path)
        if read_data.length > 0
          read_data = JSON.parse(read_data)
          if !key.nil?
            return false if read_data[key] == attributes
            attributes =
              if read_data.key?(key)
                read_data[key].merge(attributes)
              else
                attributes
              end
          else
            return false if read_data == attributes
            attributes = read_data.merge(attributes)
          end
        else
          attributes = { key => attributes } unless key.nil?
        end
        @zk.set(abs_node_path, attributes.to_json, version: stat.version)
      else
        attributes = { key => attributes } unless key.nil?
        @zk.create(abs_node_path, attributes.to_json)
      end
      true
    end

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

    def close
      @zk.close
    end
  end
end
