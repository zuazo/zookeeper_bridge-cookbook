# encoding: UTF-8

def whyrun_supported?
  true
end

def server
  new_resource.server || node['zookeeper_bridge']['server']
end

action :run do
  converge_by("run #{new_resource}") do
    zk_locker = Chef::ZookeeperBridge::Locker.new(server)
    zk_locker.semaphore(
      new_resource.path,
      new_resource.size,
      new_resource.wait
    ) do
      recipe_eval(&new_resource.block)
    end
    zk_locker.close
  end
end
