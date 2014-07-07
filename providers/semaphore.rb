action :run do
  server = new_resource.server || node['zookeeper_bridge']['zookeeper']['server']
  zkb = Chef::ZookeeperBridge.new(server)
  # provider = self
  zkb.semaphore(new_resource.path, new_resource.size, new_resource.wait) do
    recipe_eval(&new_resource.block)
  end
  zkb.close
end
