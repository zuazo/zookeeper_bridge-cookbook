# encoding: UTF-8

def server
  new_resource.server || node['zookeeper_bridge']['server']
end

action :run do
  zk_locker = Chef::ZookeeperBridge::Locker.new(server)
  zk_locker.shared_lock(new_resource.path, new_resource.wait) do
    recipe_eval(&new_resource.block)
  end
  zk_locker.close
end
