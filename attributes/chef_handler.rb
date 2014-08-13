default['zookeeper_bridge']['chef_handler']['version'] = nil
default['zookeeper_bridge']['chef_handler']['znode'] =
  "/chef/#{node['fqdn']}/status"
