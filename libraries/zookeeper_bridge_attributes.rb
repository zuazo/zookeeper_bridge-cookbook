# encoding: UTF-8

class Chef
  class ZookeeperBridge
    # ZooKeeper logic to read/write node attributes
    class Attributes < ZookeeperBridge
      private

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
        !@zk.create(path, attrs.to_json).nil?
      end

      def zk_merge_hash(path, attrs, key = nil, encoding = nil)
        # TODO: test this hash merge properly
        attrs = force_encoding(attributes, encoding) unless encoding.nil?
        orig_attrs, ver = zk_read_hash(path, encoding, true)
        if !key.nil? # TODO: use DeepMerge here
          attrs = orig_attrs[key].merge(attrs) if orig_attrs.key?(key)
        else
          attrs = orig_attrs.merge(attrs)
        end
        orig_attrs != attrs ? !@zk.set(path, attrs.to_json, ver).nil? : false
      end

      public

      def read(path, attributes, key = nil, encoding = nil)
        attrs, _version = zk_read_hash(path, encoding, false)
        unless key.nil?
          return false unless attrs.key?(key)
          attrs = attrs[key] unless key.nil?
        end
        Chef::Mixin::DeepMerge.hash_only_merge!(attributes, attrs)
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
