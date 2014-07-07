action :run do
  server = new_resource.server || node['zookeeper_bridge']['zookeeper']['server']
  zkb = Chef::ZookeeperBridge.new(server)
  zkb.shared_lock(new_resource.path, new_resource.wait) do
    recipe_eval(&new_resource.block)
  end
  zkb.close
end
