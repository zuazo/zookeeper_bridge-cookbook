def server
  new_resource.server || node['zookeeper_bridge']['server']
end

action :run do
  zkb = Chef::ZookeeperBridge.new(server)
  zkb.exclusive_lock(new_resource.path, new_resource.wait) do
    recipe_eval(&new_resource.block)
  end
  zkb.close
end
