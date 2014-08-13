def server
  new_resource.server || node['zookeeper_bridge']['server']
end

action :wait do
  zkb = Chef::ZookeeperBridge.new(server)
  case new_resource.status.to_sym
  when :created
    zkb.block_until_znode_created(new_resource.path)
  when :deleted
    zkb.block_until_znode_deleted(new_resource.path)
  end
  unless new_resource.event.to_sym == :none
    zkb.block_until_znode_event(new_resource.path, new_resource.event)
  end
  zkb.close
end
