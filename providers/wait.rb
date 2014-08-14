# encoding: UTF-8

def whyrun_supported?
  true
end

def server
  new_resource.server || node['zookeeper_bridge']['server']
end

action :wait do
  converge_by("wait #{new_resource}") do
    zk_locker = Chef::ZookeeperBridge::StatusLocker.new(server)
    case new_resource.status.to_sym
    when :created
      zk_locker.until_znode_created(new_resource.path)
    when :deleted
      zk_locker.until_znode_deleted(new_resource.path)
    end
    unless new_resource.event.to_sym == :none
      zk_locker.until_znode_event(new_resource.path, new_resource.event)
    end
    zk_locker.close
  end
end
