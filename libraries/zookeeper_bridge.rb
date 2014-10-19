# encoding: UTF-8

# Based on ZK gem examples:
#   https://github.com/zk-ruby/zk/blob/master/docs/examples

class Chef
  # Chef helpers to interact with ZooKeeper
  class ZookeeperBridge
    class ZkHashFormatError < StandardError; end

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

    public

    def initialize(server)
      Chef::ZookeeperBridge::Depends.load
      @zk = ZK.new(server)
    end

    # TODO: avoid #dirname & #basename to support non-unix platforms
    def path_to_name_and_root_node(path)
      path = path.gsub(/\/*$/, '')
      result = []
      result[0] = path[0] == '/' ? ::File.dirname(path) : nil
      result[0] = nil if result[0] == '.'
      result[1] = result[0].nil? ? path : ::File.basename(path)
      result
    end

    def close
      @zk.close
    end
  end # ZookeeperBridge
end
