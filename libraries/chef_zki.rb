
require 'json'
begin
  require 'zk'
rescue LoadError
  Chef::Log.info("Missing gem 'zk'")
end

class Chef
  class Zki

    class Depends
      def self.load
        unless defined?(ZK)
          Chef::Log.info("Trying to load 'zk' at runtime.")
          Gem.clear_paths
          require 'zk'
        end
      end
    end

    def initialize(server)
      Chef::Zki::Depends.load
      @zk = ZK.new(server)
    end

    # Based on ZK gem examples:
    #   https://github.com/zk-ruby/zk/blob/master/docs/examples

    def block_until_znode_event(abs_node_path, event_types)
      queue = Queue.new
      event_types_hs = Hash[ [event_types].flatten.map{ |v| ["ZOO_#{v.to_s.upcase}_EVENT", v.to_sym] } ]

      ev_sub = @zk.register(abs_node_path) do |event|
        queue.enq(event_types_hs[event.event_name]) if event_types_hs.has_key?(event.event_name)
      end
      @zk.stat(abs_node_path, :watch => true)

      queue.pop # block waiting for node change
    ensure
      ev_sub.unsubscribe
    end

    def block_until_znode_created(abs_node_path)
      queue = Queue.new

      ev_sub = @zk.register(abs_node_path) do |event|
        if event.node_created?
          queue.enq(:created)
        else
          if @zk.exists?(abs_node_path, :watch => true)
            # ooh! surprise! There it is!
            queue.enq(:created)
          end
        end
      end

      # set up the callback, but bail if we don't need to wait
      return true if @zk.exists?(abs_node_path, :watch => true)

      queue.pop # block waiting for node creation
      true
    ensure
      ev_sub.unsubscribe
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
          unless @zk.exists?(abs_node_path, :watch => true)
            # ooh! surprise! it's gone!
            queue.enq(:deleted)
          end
        end
      end

      # set up the callback, but bail if we don't need to wait
      return true unless @zk.exists?(abs_node_path, :watch => true)

      queue.pop # block waiting for node deletion
      true
    ensure
      ev_sub.unsubscribe
    end

    def attributes_read(abs_node_path, attributes, key=nil)
      attrs, stat = @zk.get(abs_node_path)
      if attrs.kind_of?(String)
        attrs = JSON.parse(attrs)
        unless key.nil?
          return false unless attrs.has_key?(key)
          attrs = attrs[key] unless key.nil?
        end
        attributes.merge!(attrs)
        return true
      end
      return false
    end

    def attributes_write(abs_node_path, attributes, key=nil)
      attributes = attributes.to_hash
      if @zk.exists?(abs_node_path)
        # TODO: test this hash merge properly
        read_data, stat = @zk.get(abs_node_path)
        if read_data.length > 0
          read_data = JSON.parse(read_data)
          unless key.nil?
            return false if read_data[key] === attributes
            attributes = read_data.has_key?(key) ? read_data[key].merge(attributes) : attributes
          else
            return false if read_data === attributes
            attributes = read_data.merge(attributes)
          end
        else
          attributes = { key => attributes } unless key.nil?
        end
        @zk.set(abs_node_path, attributes.to_json, :version => stat.version)
      else
        attributes = { key => attributes } unless key.nil?
        @zk.create(abs_node_path, attributes.to_json)
      end
      return true
    end

    def close
      @zk.close
    end

  end
end

