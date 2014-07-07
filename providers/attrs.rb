
action :read do
  if not new_resource.attribute.kind_of?(Chef::Node::VividMash)
    raise ArgumentError, "wrong node attribute: you should use writable node attributes like node.defaut[...] or node.normal[...]."
  end
  server = new_resource.server || node['zookeeper_bridge']['zookeeper']['server']
  zkb = Chef::ZookeeperBridge.new(server)
  new_resource.updated_by_last_action(
    zkb.attributes_read(new_resource.path, new_resource.attribute, new_resource.key, new_resource.force_encoding) === true
  )
  zkb.close
end

action :write do
  if new_resource.attribute.kind_of?(Chef::Node) or new_resource.attribute.kind_of?(Chef::Node::Attribute)
      attribute = new_resource.attribute.merged_attributes
  else
      attribute = new_resource.attribute
  end
  if not attribute.kind_of?(Chef::Node::ImmutableMash)
    raise ArgumentError, "wrong node attribute (#{attribute.class.name}): you should use readable node attributes like node[...]."
  end
  server = new_resource.server || node['zookeeper_bridge']['zookeeper']['server']
  zkb = Chef::ZookeeperBridge.new(server)
  new_resource.updated_by_last_action(
    zkb.attributes_write(new_resource.path, attribute, new_resource.key, new_resource.force_encoding) === true
  )
  zkb.close
end

